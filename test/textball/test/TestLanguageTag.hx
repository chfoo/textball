package textball.test;

import utest.Assert;


class TestLanguageTag {
    public function new() {

    }

    public function testFromGettextTag() {
        var tag1 = LanguageTag.fromGettextTag("sv_ES");
        var tag2 = LanguageTag.fromGettextTag("sv_ES.UTF-8");
        var tag3 = LanguageTag.fromGettextTag("sv_ES@variant");

        Assert.equals("sv-ES", tag1);
        Assert.equals("sv-ES", tag2);
        Assert.equals("sv-ES", tag3);
    }

    public function testFromArray() {
        var tag = LanguageTag.fromArray(["sgn", "BE", "FR"]);

        Assert.equals("sgn-BE-FR", tag);
    }

    public function testSubtags() {
        var tag = new LanguageTag("sgn-BE-FR");

        Assert.same(["sgn", "BE", "FR"], tag.subtags);
    }

    public function testEquals() {
        var tag = new LanguageTag("sgn-BE-FR");

        Assert.isTrue(tag.equals("sgn-be-fr"));
    }

    // public function testMatch() {
    //     var tag = new LanguageTag("sgn-BE-FR");

    //     Assert.same(["sgn", "BE", "FR"], tag.match("sgn-be-fr"));
    //     Assert.same(["sgn", "BE"], tag.match("sgn-be-xx"));
    //     Assert.same(["sgn", "BE", "FR"], tag.match("sgn-be-fr-xx"));
    //     Assert.same(["sgn", "BE"], tag.match("sgn-be"));
    //     Assert.same(["sgn"], tag.match("sgn"));
    //     Assert.same([], tag.match("xx"));
    // }
}
