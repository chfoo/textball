package textball.test;

import haxe.io.Bytes;
import resdb.Database;
import resdb.PageStore;
import textball.simple.CatalogBuilder;
import textball.simple.ResourceCatalog;
import utest.Assert;


class MockPageStore implements PageStore {
    var pageData:Array<Bytes>;

    public function new(pageData:Array<Bytes>) {
        this.pageData = pageData;
    }

    public function getPage(page:Int):Bytes {
        return pageData[page];
    }
}


class TestResource {
    public function new() {
    }

    static function buildCatalog() {
        var catalogBuilder = new CatalogBuilder("test_catalog");
        var localeBuilder = catalogBuilder.addLocale("x-test");

        localeBuilder.addPluralFormula(2, "n == 1 ? 0 : 1");
        localeBuilder.addText("Hello world!", "Hello test!");
        localeBuilder.addString(1, "Hello test!");
        localeBuilder.addTextPlural("::num:: file", "::num:: files",
            ["::num:: test", "::num:: tests"]);
        localeBuilder.addStringPlural(2, ["::num:: test", "::num:: tests"]);

        return catalogBuilder;
    }

    #if macro
    public static function embed() {
        buildCatalog().embed();
    }
    #end

    public function testAllInMemory() {
        var pageStore = new MockPageStore(buildCatalog().getPageData());
        var database = new Database({ name: "test_catalog"}, pageStore);
        var catalog = new ResourceCatalog(database);
        var translator = new Translator(catalog);

        translator.languageTags = ["x-test"];

        Assert.equals("Hello test!", translator.getText("Hello world!"));

        Assert.equals("Hello test!", translator.getString(1));

        Assert.equals("::num:: test", translator.getTextPlural("::num:: file", "::num:: files", 1));
        Assert.equals("::num:: tests", translator.getTextPlural("::num:: file", "::num:: files", 2));

        Assert.equals("::num:: test", translator.getStringPlural(2, 1));
        Assert.equals("::num:: tests", translator.getStringPlural(2, 2));
    }

    public function testResourceEmbed() {
        var catalog = ResourceCatalog.loadResource("test_catalog");
        var translator = new Translator(catalog);

        translator.languageTags = ["x-test"];

        Assert.equals("Hello test!", translator.getText("Hello world!"));
    }

    #if sys
    public function testFilesystem() {
        buildCatalog().save("out/tmp/");
        var catalog = ResourceCatalog.load("out/tmp/", "test_catalog");
        var translator = new Translator(catalog);

        translator.languageTags = ["x-test"];

        Assert.equals("Hello test!", translator.getText("Hello world!"));
    }
    #end
}
