package textball.example;

import haxe.Template;
import textball.simple.ResourceCatalog;
import textball.Textball;
import textball.Textball.getString as S;
import textball.Textball.getStringPlural as SN;

#if macro
import textball.simple.CSVLoader;
#end


class Example {
    static inline var RESOURCE_NAME = "strings";

    #if macro
    // This method is called during compilation time.
    public static function embedStrings() {
        var csvLoader = new CSVLoader(RESOURCE_NAME);
        csvLoader.loadDirectory("example/csv/", true);
        csvLoader.catalogBuilder.embed();
    }
    #end

    public static function main() {
        var catalog = ResourceCatalog.loadResource(RESOURCE_NAME);
        Textball.translator.catalog = catalog;
        Textball.translator.detectLanguage();

        trace('User language tags: ${Textball.translator.languageTags}');
        trace("Text demo:");
        trace(S(1));

        trace("Plural demo:");

        for (n in 0...3) {
            var string = SN(2, n);
            trace(new Template(string).execute({ num: n }));
        }
    }
}
