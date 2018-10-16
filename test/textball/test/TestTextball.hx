package textball.test;

import utest.Assert;


class TestTextball {
    public function new() {
    }

    public function testTestballPassthroughToEnUS() {
        Textball.translator.detectLanguage();

        Assert.equals("Hello world!", Textball.getText("Hello world!"));

        Assert.equals("[1]", Textball.getString(1));

        Assert.equals("::num:: file", Textball.getTextPlural("::num:: file", "::num:: files", 1));
        Assert.equals("::num:: files", Textball.getTextPlural("::num:: file", "::num:: files", 2));
        Assert.equals("::num:: horses", Textball.getTextPlural("::num:: horse", "::num:: horses", 999));

        Assert.equals("[1-1]", Textball.getStringPlural(1, 1));
        Assert.equals("[1-2]", Textball.getStringPlural(1, 2));
    }
}
