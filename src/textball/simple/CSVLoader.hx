package textball.simple;

import haxe.ds.Vector;
import sys.FileSystem;
import sys.io.File;
import haxe.io.Path;
import textball.simple.CatalogBuilder;
import format.csv.Reader;

using StringTools;


/**
    Reads from CSV files and loads the translations into a catalog builder.
**/
class CSVLoader {
    public static inline var PLURAL_FORMULA = "__plural_formula__";
    public static var COLUMNS = ["id", "plural_id", "string"];

    /**
        The catalog builder containing the loaded translations.
    **/
    public var catalogBuilder(get, never):CatalogBuilder;

    var _catalogBuilder:CatalogBuilder;

    /**
        @param name Name of the resource.
    **/
    public function new(name:String) {
        _catalogBuilder = new CatalogBuilder(name);
    }

    function get_catalogBuilder():CatalogBuilder {
        return _catalogBuilder;
    }

    /**
        Loads CSV files from a directory.

        This method does not load from the directory recursively.

        @param dirPath Path of the directory.
        @param skipHeader Whether the first row of the CSV file should be
            treated as a header and skipped.
        @param extension Filename extension of the CSV files.
    **/
    public function loadDirectory(dirPath:String, skipHeader:Bool = false,
            extension:String = ".csv") {
        for (filename in FileSystem.readDirectory(dirPath)) {
            var path = Path.join([dirPath, filename]);

            if (FileSystem.isDirectory(path) || !path.endsWith(extension)) {
                continue;
            }

            loadFile(path, skipHeader);
        }
    }

    /**
        Load a CSV file.

        @param filename Path of the file.
        @param skipHeader Whether the first row of the CSV file should be
            treated as a header and skipped.
    **/
    public function loadFile(filename:String, skipHeader:Bool = false) {
        var path = new Path(filename);
        var languageTag = path.file;
        loadString(File.getContent(filename), languageTag, skipHeader);
    }

    /**
        Load a CSV formatted string.

        @param content A string containing CSV formatted data.
        @param languageTag IETF language tag.
        @param skipHeader Whether the first row of the CSV file should be
            treated as a header and skipped.
    **/
    public function loadString(content:String, languageTag:String,
            skipHeader:Bool = false) {
        var localeLoader = new LocaleLoader(
            _catalogBuilder.addLocale(languageTag));
        localeLoader.loadString(content, skipHeader);
    }
}


private class LocaleLoader {
    var localeBuilder:LocaleCatalogBuilder;
    var pluralNumberForms = 0;
    var pendingPluralForms:Map<Int,Vector<String>>;

    public function new(localeBuilder:LocaleCatalogBuilder) {
        this.localeBuilder = localeBuilder;
        pendingPluralForms = new Map();
    }

    public function loadString(content:String, skipHeader:Bool = false) {
        var skipHeaderNeeded = skipHeader;

        for (line in Reader.parseCsv(content)) {
            if (skipHeaderNeeded) {
                skipHeaderNeeded = false;
                continue;
            }

            if (line.length < CSVLoader.COLUMNS.length) {
                continue;
            }

            loadLine(line);
        }

        processPendingPluralForms();
    }

    function loadLine(line:Array<String>) {
        if (line[0] == "") {
            return;
        }

        if (line[0] == CSVLoader.PLURAL_FORMULA) {
            processPluralFormulaLine(line);
        } else {
            processLine(line);
        }
    }

    function processPluralFormulaLine(line:Array<String>) {
        pluralNumberForms = parseInt(line[1]);
        localeBuilder.addPluralFormula(pluralNumberForms, line[2]);
    }

    function processLine(line:Array<String>) {
        var idColumn = line[0];
        var pluralIDColumn = line[1];
        var stringColumn = line[2];

        if (pluralIDColumn == "") {
            localeBuilder.addString(parseInt(idColumn), stringColumn);
        } else {
            var id = parseInt(idColumn);
            var pluralID = parseInt(pluralIDColumn);

            if (pluralID + 1 > pluralNumberForms) {
                throw new Exception('String ID $id-$pluralID exceeds number of plural forms ($pluralNumberForms)');
            }

            if (!pendingPluralForms.exists(id)) {
                pendingPluralForms.set(id, new Vector(pluralNumberForms));
            }

            pendingPluralForms.get(id).set(pluralID, stringColumn);
        }
    }

    function processPendingPluralForms() {
        for (id in pendingPluralForms.keys()) {
            var forms = pendingPluralForms.get(id).toArray();
            localeBuilder.addStringPlural(id, forms);
        }
    }

    static function parseInt(value:String):Int {
        var result = Std.parseInt(value);

        if (result == null) {
            throw new Exception('Cannot parse "$value" as integer');
        }

        return result;
    }
}
