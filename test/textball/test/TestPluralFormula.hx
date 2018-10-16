package textball.test;

import utest.Assert;


class TestPluralFormula {
    public function new() {
    }

    public function test3Forms() {
        var formula = new PluralFormula(
            3,
            "n == 0 ? 0 :
            n % 2 == 0 ? 1 : 2");

        Assert.equals(0, formula.getForm(0));
        Assert.equals(2, formula.getForm(1));
        Assert.equals(1, formula.getForm(2));
        Assert.equals(1, formula.getForm(100));
        Assert.equals(2, formula.getForm(101));
    }

    public function testOutOfRange() {
        var formula = new PluralFormula(2, "n == 0 ? -999 : 999");

        Assert.raises(formula.getForm.bind(-1), textball.Exception);
        Assert.raises(formula.getForm.bind(0), textball.Exception);
        Assert.raises(formula.getForm.bind(1), textball.Exception);
    }
}
