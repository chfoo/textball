package textball;

import openfl.display.Sprite;
import textball.simple.ResourceCatalog;


class TestResourceOpenFL extends Sprite {
    public function new() {
        super();

        var catalog = ResourceCatalog.loadOpenFLAsset("assets/test_catalog");
        var translator = new Translator(catalog);

        translator.languageTags = ["x-test"];

        if (translator.getText("Hello world!") == "Hello test!") {
            trace("ok");
            Sys.exit(0);
        } else {
            trace("fail");
            Sys.exit(1);
        }
    }
}
