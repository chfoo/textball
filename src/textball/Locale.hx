package textball;

import haxe.ds.Option;


/**
    Represents an interface for text translation to a language.
**/
interface Locale {
    /**
        IETF language tag of the locale.
    **/
    public var languageTag(get, never):LanguageTag;

    /**
        Returns the localized text for the given text.

        @param text English/untranslated text.
    **/
    public function getText(text:String):Option<String>;

    /**
        Returns the localized text for the given string ID.

        @param id String ID.
    **/
    public function getString(id:Int):Option<String>;

    /**
        Returns the localized plural form text for the given text and number.

        @param singular English text in the singular form.
        @param plural English text in the plural form.
        @param count Number being considered.
    **/
    public function getTextPlural(singular:String, plural:String,
        count:Int):Option<String>;

    /**
        Returns the localized plural form text for the given string ID and
        number.

        @param id String ID.
        @param count Number being considered. Must be in range of
            [0, 2147483647].
    **/
    public function getStringPlural(id:Int, count:Int):Option<String>;
}
