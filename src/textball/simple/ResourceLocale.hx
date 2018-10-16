package textball.simple;

import haxe.ds.Option;


/**
    `Locale` implementation for `ResourceCatalog`.
**/
class ResourceLocale implements Locale {
    public var languageTag(get, never):LanguageTag;

    var _languageTag:String;
    var catalog:ResourceCatalog;
    var pluralFormula:PluralFormula;

    public function new(languageTag:LanguageTag, catalog:ResourceCatalog) {
        _languageTag = languageTag;
        this.catalog = catalog;
        pluralFormula = catalog.getPluralFormula(languageTag);
    }

    function get_languageTag():String {
        return _languageTag;
    }

    public function getText(text:String):Option<String> {
        return catalog.getText(_languageTag, text);
    }

    public function getString(id:Int):Option<String> {
        return catalog.getString(_languageTag, id);
    }

    public function getTextPlural(singular:String, plural:String, count:Int)
            :Option<String> {
        switch catalog.getTextPluralArray(_languageTag, singular) {
            case Some(array):
                return getPluralCommon(count, array);
            default:
                return None;
        }
    }

    public function getStringPlural(id:Int, count:Int):Option<String> {
        switch catalog.getStringPluralArray(_languageTag, id) {
            case Some(array):
                return getPluralCommon(count, array);
            default:
                return None;
        }
    }

    function getPluralCommon(count:Int, array:Array<String>)
            :Option<String> {
        var index = pluralFormula.getForm(count);

        if (index < array.length) {
            return Some(array[index]);
        } else {
            return None;
        }
    }
}
