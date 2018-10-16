package textball;

import haxe.ds.Option;


/**
    Source for locale instances.
**/
interface Catalog {
    /**
        Returns the locale for the given language tag.

        @param languageTag IETF language tag.
    **/
    public function getLocale(languageTag:LanguageTag):Option<Locale>;
}
