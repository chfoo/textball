package textball;

using StringTools;


/**
    String containing a IETF language tag.
**/
@:forward
abstract LanguageTag(String) to String from String {
    /**
        An array of subtags. A tag contains one or more components separated by
        a hyphen.
    **/
    public var subtags(get, never):Array<String>;

    static var gettextTagPattern = new EReg("[a-zA-Z0-9-]*", "");

    function get_subtags():Array<String> {
        return this.split("-");
    }

    inline public function new(tag:String) {
        this = tag;
    }

    /**
        Returns a IETF language tag from a GNU Gettext language tag.
        A Gettext language tag is similar to a IETF language tag but includes
        additional fields such as `@variant` and `.encoding`.
    **/
    public static function fromGettextTag(tag:String):LanguageTag {
        tag = tag.replace("_", "-");

        if (gettextTagPattern.match(tag)) {
            return gettextTagPattern.matched(0);
        } else {
            return "";
        }
    }

    /**
        Returns a language tag from an array of subtags.
    **/
    public static function fromArray(subtags:Array<String>):LanguageTag {
        return subtags.join("-");
    }

    /**
        Returns whether the subtags are the same.
    **/
    public function equals(other:LanguageTag):Bool {
        return this.toLowerCase() == other.toLowerCase();
    }
}
