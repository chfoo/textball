package textball.simple;

import haxe.ds.Option;
import org.msgpack.MsgPack;
import resdb.Database;
import resdb.store.ResourcePageStore;

using textball.simple.DatabaseTools;


/**
    Catalog using Resdb as the store of the translation sources.

    To generate the data store for the database, see `CatalogBuilder`.
**/
class ResourceCatalog implements Catalog {
    public static inline var LANGUAGE_TAGS = "__language_tags__";
    public static inline var PLURAL_FORMULA = "__plural_formula__";

    var database:Database;
    var languageTags:Array<String>;

    /**
        @param database A `resdb.Database` instance.
    **/
    public function new(database:Database) {
        this.database = database;

        languageTags = getLanguageTags();
    }

    function getLanguageTags():Array<String> {
        switch database.stringGet("", LANGUAGE_TAGS) {
            case Some(data):
                return MsgPack.decode(data);
            default:
                throw new Exception("Language tags missing");
        }
    }

    /**
        Returns a catalog loaded from Haxe's resource embedding system.

        @param name Name of the resource.
    **/
    public static function loadResource(name:String):ResourceCatalog {
        var database = ResourcePageStore.getDatabase({ name: name });
        return new ResourceCatalog(database);
    }

    #if (sys || doc_gen)
    /**
        Returns a catalog loaded from the filesystem.

        @param rootDirectory Path of the resource/asset directory.
        @param name Filename or asset name.
    **/
    public static function load(rootDirectory:String, name:String)
            :ResourceCatalog {
        var database = resdb.store.FilePageStore.getDatabase(
            { rootDirectory: rootDirectory, name: name}
        );
        return new ResourceCatalog(database);
    }
    #end

    #if (openfl || doc_gen)
    /**
        Returns a catalog loaded using OpenFL's asset system.

        @param name Asset name.
    **/
    public static function loadOpenFLAsset(name:String):ResourceCatalog {
        var database = resdb.store.OpenFLAssetPageStore.getDatabase(
            { name: name }
        );
        return new ResourceCatalog(database);
    }
    #end

    public function getLocale(languageTag:LanguageTag):Option<Locale> {
        if (languageTags.indexOf(languageTag) >= 0) {
            return Some((new ResourceLocale(languageTag, this):Locale));
        } else {
            return None;
        }
    }

    @:allow(textball.simple)
    function getPluralFormula(languageTag:String):PluralFormula {
        switch database.stringGet(languageTag, PLURAL_FORMULA) {
            case Some(data):
                var dataStruct:PluralFormulaDataStruct = MsgPack.decode(data);
                return new PluralFormula(dataStruct.numForms, dataStruct.formula);
            case None:
                throw new Exception('Missing plural formula: $languageTag');
        }
    }

    @:allow(textball.simple)
    function getText(languageTag:String, text:String):Option<String> {
        return database.stringGetString(languageTag, text);
    }

    @:allow(textball.simple)
    function getString(languageTag:String, id:Int):Option<String> {
        return database.intGetString(languageTag, id);
    }

    @:allow(textball.simple)
    function getTextPluralArray(languageTag:String, singular:String)
            :Option<Array<String>> {
        return database.stringGetArray(languageTag, singular);
    }

    @:allow(textball.simple)
    function getStringPluralArray(languageTag:String, id:Int)
            :Option<Array<String>> {
        return database.intGetArray(languageTag, id);
    }
}
