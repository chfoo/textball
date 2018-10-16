package textball;


/**
    Convenience methods for using the global `Translator`.
**/
class Textball {
    /**
        Current global `Translator` instance.
    **/
    public static var translator(get, set):Translator;

    static var _translator:Translator = new Translator();

    static function get_translator():Translator {
        return _translator;
    }

    static function set_translator(value:Translator):Translator {
        return _translator = value;
    }

    /**
        Returns the localized text for the given text.

        See `Translator.getText`.
    **/
    public static function getText(text:String):String {
        return _translator.getText(text);
    }

    /**
        Returns the localized text for the given string ID.

        See `Translator.getString`.
    **/
    public static function getString(id:Int):String {
        return _translator.getString(id);
    }

    /**
        Returns the localized plural form text for the given text and number.

        See `Translator.getTextPlural`.
    **/
    public static function getTextPlural(singular:String, plural:String,
            count:Int):String {
        return _translator.getTextPlural(singular, plural, count);
    }

    /**
        Returns the localized plural form text for the given string ID and
        number.

        See `Translator.getStringPlural`.
    **/
    public static function getStringPlural(id:Int, count:Int):String {
        return _translator.getStringPlural(id, count);
    }
}
