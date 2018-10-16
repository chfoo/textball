package textball;


/**
    Retrieves text from appropriate locales.

    This class will handle retrieving text from locales, falling back
    to another locales, and then finally falling back to the passthrough
    locale.

    This class supports two types of text localization, gettext-style and
    string IDs. By default, the class is set up for gettext-style
    passthrough of en-US text. Setting a catalog and specifying a language
    is required before the class can be used for other locales.

    Applications will typically use this class globally with the `Textball`
    class.
**/
class Translator {
    /**
        `Catalog` instance where `Locale` instances are loaded.
    **/
    public var catalog(get, set):Catalog;

    /**
        IETF language tags, in order, from which text is retrieved.

        By default, this is an empty array.
    **/
    public var languageTags(get, set):Array<LanguageTag>;

    /**
        Locale for gettext-style text passthrough.

        By default, this is an instance of `PassthroughLocale`. It will be
        invoked when there are no languages are set.
    **/
    public var passthroughLocale(get, set):Locale;

    var _catalog:Catalog;
    var _languageTags:Array<LanguageTag>;
    var _locales:Array<Locale>;
    var _passthroughLocale:Locale;

    public function new(?catalog:Catalog) {
        if (catalog == null) {
            catalog = new DummyCatalog();
        }

        _catalog = catalog;
        _languageTags = [];
        _passthroughLocale = new PassthroughLocale();
        _locales = [_passthroughLocale];
    }

    function get_catalog():Catalog {
        return _catalog;
    }

    function set_catalog(value:Catalog):Catalog {
        return _catalog = value;
    }

    function get_languageTags():Array<LanguageTag> {
        return _languageTags;
    }

    function set_languageTags(value:Array<LanguageTag>):Array<LanguageTag> {
        _languageTags = value;
        _locales = [];
        var pendingTags = _languageTags.copy();

        while (pendingTags.length > 0) {
            for (tag in pendingTags.copy()) {
                switch _catalog.getLocale(tag) {
                    case Some(locale):
                        _locales.push(locale);
                        pendingTags.remove(tag);
                    case None:
                        continue;
                }
            }

            pendingTags = truncateTags(pendingTags);
        }

        _locales.push(_passthroughLocale);

        return value;
    }

    function get_passthroughLocale():Locale {
        return _passthroughLocale;
    }

    function set_passthroughLocale(value:Locale):Locale {
        _locales[_locales.length - 1] = value;
        return _passthroughLocale = value;
    }

    function truncateTags(tags:Array<LanguageTag>):Array<LanguageTag> {
        var truncatedTags = [];

        for (tag in tags) {
            var subtags = tag.subtags;

            if (subtags.length > 1) {
                truncatedTags.push(LanguageTag.fromArray(subtags.slice(0, -1)));
            }
        }

        return truncatedTags;
    }

    /**
        Detects the language of the user and sets the class to the language.

        This method supports detecting language from:

        * sys: `LANG` and `LANGUAGE` GNU Gettext environment variables
        * Javascript: `navigator.languages`

        Returns true if it succeeded.
    **/
    public function detectLanguage():Bool {
        #if sys
        var env = Sys.environment();
        var tags = [];

        if (env.exists("LANG")) {
            tags.push(LanguageTag.fromGettextTag(env.get("LANG")));
        }

        if (env.exists("LANGUAGE")) {
            var envTags = env.get("LANGUAGE").split(":");
            for (tag in envTags) {
                tags.push(LanguageTag.fromGettextTag(tag));
            }
        }

        languageTags = tags;
        return tags.length > 0;

        #elseif js
        var tags = js.Browser.navigator.languages;
        languageTags = tags;
        return tags.length > 0;

        #else
        return false;
        #end
    }

    /**
        Returns the localized text for the given text.

        See `Locale.getText`.
    **/
    public function getText(text:String):String {
        for (locale in _locales) {
            switch locale.getText(text) {
                case Some(result): return result;
                default: continue;
            }
        }

        return text;
    }

    /**
        Returns the localized text for the given string ID.

        See `Locale.getString`.
    **/
    public function getString(id:Int):String {
        for (locale in _locales) {
            switch locale.getString(id) {
                case Some(result): return result;
                default: continue;
            }
        }

        return '[$id]';
    }

    /**
        Returns the localized plural form text for the given text and number.

        See `Locale.getTextPlural`.
    **/
    public function getTextPlural(singular:String, plural:String,
            count:Int):String {
        for (locale in _locales) {
            switch locale.getTextPlural(singular, plural, count) {
                case Some(result): return result;
                default: continue;
            }
        }

        return plural;
    }

    /**
        Returns the localized plural form text for the given string ID and
        number.

        See `Locale.getStringPlural`.
    **/
    public function getStringPlural(id:Int, count:Int):String {
        for (locale in _locales) {
            switch locale.getStringPlural(id, count) {
                case Some(result): return result;
                default: continue;
            }
        }

        return '[$id-$count]';
    }
}
