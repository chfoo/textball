package textball;

import haxe.ds.Option;


/**
    Locale for gettext-style text passthrough.

    This locale is used for returning the application native strings unmodified
    for applications using the gettext-style of localization. By default,
    this locale is for en-US.
**/
class PassthroughLocale implements Locale {
    public var languageTag(get, never):String;

    var _languageTag:LanguageTag;
    var pluralFormula:PluralFormula;

    public function new(languageTag:LanguageTag = "en-US",
            ?pluralFormula:PluralFormula) {
        _languageTag = languageTag;
        this.pluralFormula = pluralFormula != null ?
            pluralFormula : new PluralFormula();
    }

    function get_languageTag():LanguageTag {
        return _languageTag;
    }

    public function getText(text:String):Option<String> {
        return Some(text);
    }

    public function getString(id:Int):Option<String> {
        return Some('[$id]');
    }

    public function getTextPlural(singular:String, plural:String,
            count:Int):Option<String> {
        if (pluralFormula.getForm(count) == 0) {
            return Some(singular);
        } else {
            return Some(plural);
        }
    }

    public function getStringPlural(id:Int, count:Int):Option<String> {
        return Some('[$id-$count]');
    }
}
