package textball.test;

import haxe.ds.Option;
import utest.Assert;


class MockCatalog implements Catalog {
    public function new() {
    }

    public function getLocale(languageTag:String):Option<Locale> {
        if (languageTag == "x-test") {
            return Some((new MockLocale():Locale));
        } else {
            return None;
        }
    }
}


class MockLocale implements Locale {
    public function new() {
    }

    public var languageTag(get, never):String;

    function get_languageTag():String {
        return "x-test";
    }

    public function getText(text:String):Option<String> {
        if (text == "Hello world!") {
            return Some("Hello test!");
        } else {
            return None;
        }
    }

    public function getString(id:Int):Option<String> {
        if (id == 1) {
           return Some("Hello test!");
        } else {
            return None;
        }
    }

    public function getTextPlural(singular:String, plural:String,
            count:Int):Option<String> {
        if (count == 1 && singular == "::num:: file") {
            return Some("::num:: test");
        } else if (count != 1 && plural == "::num:: files" ) {
            return Some("::num:: tests");
        } else {
            return None;
        }
    }

    public function getStringPlural(id:Int, count:Int):Option<String> {
        if (count == 1 && id == 1) {
            return Some("::num:: test");
        } else if (count != 1 && id == 1) {
            return Some("::num:: tests");
        } else {
            return None;
        }
    }
}


class TestTranslator {
    public function new() {
    }

    public function testTranslator() {
        var translator = new Translator();
        translator.catalog = new MockCatalog();
        translator.languageTags = ["zzz", "x-test-aaa"];

        Assert.equals("Hello test!", translator.getText("Hello world!"));
        Assert.equals("Abc", translator.getText("Abc"));

        Assert.equals("Hello test!", translator.getString(1));
        Assert.equals("[2]", translator.getString(2));

        Assert.equals("::num:: test", translator.getTextPlural("::num:: file", "::num:: files", 1));
        Assert.equals("::num:: tests", translator.getTextPlural("::num:: file", "::num:: files", 2));
        Assert.equals("::num:: horses", translator.getTextPlural("::num:: horse", "::num:: horses", 999));

        Assert.equals("::num:: test", translator.getStringPlural(1, 1));
        Assert.equals("::num:: tests", translator.getStringPlural(1, 2));
        Assert.equals("[2-999]", translator.getStringPlural(2, 999));
    }
}
