package textball.simple;

import haxe.io.Bytes;
import org.msgpack.MsgPack;
import resdb.DatabaseConfig;
import resdb.PagePacker;
import textball.simple.DatabaseTools.PluralFormulaDataStruct;

#if macro
import resdb.store.ResourceHelper;
#end

using textball.simple.PagePackerTools;


/**
    Builds the Resdb database for a `ResourceCatalog`.
**/
class CatalogBuilder {
    var dbConfig:DatabaseConfig;
    var pagePacker:PagePacker;
    var languageTags:Array<LanguageTag>;
    var pageData:Array<Bytes>;

    /**
        @param name Filename or asset name.
    **/
    public function new(name:String) {
        dbConfig = { name: name };
        pagePacker = new PagePacker(dbConfig);
        languageTags = [];
    }

    /**
        Returns a new builder for a locale.

        @param languageTag IETF language tag.
    **/
    public function addLocale(languageTag:LanguageTag):LocaleCatalogBuilder {
        languageTags.push(languageTag);
        return new LocaleCatalogBuilder(languageTag, pagePacker);
    }

    /**
        Returns the Resdb page data.

        This method is intended for custom store implementations for the
        database's page data.
    **/
    public function getPageData():Array<Bytes> {
        finalizeRecords();
        return pageData;
    }

    #if (macro || doc_gen)
    /**
        Embeds the page data using Haxe's resource embedding system.

        This method is intended to be called in a macro initializer. If
        you are generating the database beforehand, use `save`.
    **/
    public function embed() {
        #if macro
        finalizeRecords();
        ResourceHelper.addResourcePages(dbConfig.name, pageData);
        #else
        throw "macro use only";
        #end
    }
    #end

    #if (sys || doc_gen)
    /**
        Save the page data to the given directory.

        @param rootDirectory Path of the resource/asset directory.
    **/
    public function save(rootDirectory:String) {
        finalizeRecords();
        resdb.store.FilePageStore.saveDataPages(
            rootDirectory, dbConfig.name, pageData);
    }
    #end

    function finalizeRecords() {
        if (pageData == null) {
            pagePacker.stringSetArray(
                "", ResourceCatalog.LANGUAGE_TAGS, languageTags);
            pageData = pagePacker.packPages();
        }
    }
}


/**
    Methods to add translation strings to a locale.
**/
class LocaleCatalogBuilder {
    var languageTag:LanguageTag;
    var pagePacker:PagePacker;

    public function new(languageTag:LanguageTag, pagePacker:PagePacker) {
        this.languageTag = languageTag;
        this.pagePacker = pagePacker;
    }

    /**
        Adds a plural form formula.

        See `PluralFormula`.

        @param numForms Number of plural forms.
        @param formula A Haxe expression that accepts a variable `n`.
    **/
    public function addPluralFormula(numForms:Int, formula:String) {
        var dataStruct:PluralFormulaDataStruct = {
            numForms: numForms,
            formula: formula
        };

        pagePacker.stringSet(
            languageTag, ResourceCatalog.PLURAL_FORMULA,
            MsgPack.encode(dataStruct)
        );
    }

    /**
        Adds a localized text for a given text.

        See `Locale.getText`.

        @param key English/untranslated text.
        @param text Localized text.
    **/
    public function addText(key:String, text:String) {
        pagePacker.stringSetString(languageTag, key, text);
    }

    /**
        Adds a localized text for given string ID.

        See `Locale.getString`.

        @param id String ID.
        @param text Localized text.
    **/
    public function addString(id:Int, text:String) {
        pagePacker.intSetString(languageTag, id, text);
    }

    /**
        Adds localized plural form text for the given text.

        See `Locale.getTextPlural`.

        @param singular English text in the singular form.
        @param plural English text in the plural form.
        @param forms Localized plural forms.
    **/
    public function addTextPlural(singular:String, plural:String,
            forms:Array<String>) {
        pagePacker.stringSetArray(languageTag, singular, forms);
    }

    /**
        Adds localized plural form text for the given string ID.

        See `Locale.getStringPlural`.

        @param id String ID.
        @param forms Localized plural forms.
    **/
    public function addStringPlural(id:Int, forms:Array<String>) {
        pagePacker.intSetArray(languageTag, id, forms);
    }
}
