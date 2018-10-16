package textball;

import hscript.Expr;
import hscript.Interp;
import hscript.Parser;


/**
    Computes the plural form from a formula.

    See https://www.gnu.org/savannah-checkouts/gnu/gettext/manual/html_node/Plural-forms.html
    for formulas.
**/
class PluralFormula {
    public var numForms(default, null):Int;
    public var formulaText(default, null):String;
    var formulaProgram:Expr;

    /**
        @param numForms Number of plural forms.
        @param formula A Haxe expression that accepts a variable `n`.
            The expression is parsed and executed using `hscript`.
    **/
    public function new(numForms:Int = 2, formula:String = "n == 1 ? 0 : 1") {
        this.numForms = numForms;
        this.formulaText = formula;
        var parser = new Parser();
        formulaProgram = parser.parseString(formula);
    }

    /**
        Returns the plural form index from the given number.

        The index is intended to be used on an array of strings containing
        the various forms.

        @param count Number in the range [0, 2147483647].
    **/
    public function getForm(count:Int):Int {
        if (count < 0) {
            throw new Exception('Number must not be negative: $count');
        }

        var interpreter = new Interp();
        interpreter.variables.set("n", count);

        var index = interpreter.execute(formulaProgram);

        if (index < 0 || index >= numForms) {
            throw new Exception('Form index out of range: $index');
        }

        return index;
    }
}
