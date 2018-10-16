package textball;

import haxe.ds.Option;


/**
    Dummy catalog that returns nothing.
**/
class DummyCatalog implements Catalog {
    public function new() {
    }

    public function getLocale(languageTag:LanguageTag):Option<Locale> {
        return None;
    }
}
