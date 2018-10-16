Textball
========

Textball is a minimal Haxe library for i18n and localization of strings. It provides a target-independent interface and does not impose a specific format on how strings are stored and retrieved.

It is *not* a fully-featured translation toolkit or software suite. Instead, the user will bring their own implementation and processes.


Getting Started
---------------

The library is compatible with Haxe 3 or 4.

Install the library using haxelib:

    haxelib install textball

Alternatively, you get the latest from git using `haxelib git`.


### Internationalizing your strings

There are two ways of internationalizing your strings: GNU gettext style and resource integer IDs. Both methods have advantages and disadvantages.

In Gettext style, the key is the en-US string itself in the source code and the translated text is stored in resource files. Resource integer IDs, however, uses integers as the key and all text is stored in resource files.

For example, the following code shows a message to a user:

```haxe
showMessage("Discard this draft?");
```

To apply i18n in Gettext style, import a helper function and pass the string to it:

```haxe
import textball.Textball.getText as T;

// ...

showMessage(T("Discard this draft?"));
```

To use resource IDs, assign an integer to the text, import the helper function, and pass the resource ID to it:

```haxe
import textball.Textball.getString as S;

class ResourceStrings {
    public static inline var DISCARD_DRAFT_PROMPT = 1;
}

// ...

showMessage(S(ResourceStrings.DISCARD_DRAFT_PROMPT));
```

(In more sophisticated applications, the code for the integer constants is usually automatically generated from translation files. The benefit of that process is that string names can be used consistently through out the localization process instead of manually assigning integer IDs.)


### Plural support

When including numerical values in text, one may simply use an "if" statement to handle plurals as in the following example:

```haxe
if (filesTransferred == 1) {
    trace("1 file transferred");
} else {
    trace(filesTransferred + " files transferred");
}
```

This only works in English and is not very clean code.

Textball uses a concept of plural formulas borrowed from Gettext.

In Gettext style, you provide both English plural forms and the numerical value to a helper function:

```haxe
import textball.Textball.getTextPlural as TN;

var textTemplate = new Template(TN("::num:: file transferred", "::num:: files transferred", filesTransferred));
trace(textTemplate.execute({ num: filesTransferred }));
```

In resource ID style, you simply provide the ID and the numerical value:

```haxe
import textball.Textball.getStringPlural as SN;

var textTemplate = new Template(SN(ResourceString.FILES_TRANSFERRED), filesTransferred);
trace(textTemplate.execute({ num: filesTransferred });
```

In both styles above, the helper function will compute the correct plural form from the value of `filesTransferred` using the formula in the translation catalog. The catalog contains an array of strings and the formula returns an index. The returned string is then formatted with the number using the template system.


### Localizing strings

Once we modified our code, the localization process can begin.

In Gettext style, the process will involve extracting the strings from the source code and preparing files for translation.

In resource IDs style, there is no need to extract strings, the default locale uses the same resource system. All strings are moved into resource files.

In both cases, *Textball does not specify a standard or provide toolkit or software suite for the localization of strings.* Only a minimal process is built in that is called the "Simple Localization Process". This means that there is no processing programs, websites, or interoperability with other localization suites. You will need to bring your own implementation and process if the simple process is not suitable.


## Simple Localization Process

This localization process is straightforward but not very robust. It uses CSV files and the resource integer ID style.

An overview:

1. Create a CSV file named after the IETF language tag such as `en-US.csv`.
2. Add a row for the plural formula.
3. Add a row for each translatable string in your application.
4. Repeat steps 1 to 3 for each language and CSV file.
5. Import the CSV files using `CSVLoader`.
6. Generate the catalog as resource files or embedded in the application using `CatalogBuilder`.
7. On application start up, load the catalog with the resource using `ResourceCatalog`.


### CSV file format

The filename is in the format `LANGUAGE_TAG.csv` where `LANGUAGE_TAG` is an IETF language tag such as `en-US`. For example, filename the en-US locale would be `en-US.csv`.

Only the first 3 columns of the CSV file are processed. This allows users to place comments on the 4th column. The first row may be a header row, which can be ignored, for readability.

The first row, besides the header, must be the plural formula:

| Column | Type | Description |
| ------ | ---- | ----------- |
| 1 | String | Literal `__plural_formula__` |
| 2 | Integer | Number of plural forms. In English, the value is 2. |
| 3 | String | A [plural formula](https://www.gnu.org/software/gettext/manual/html_node/Plural-forms.html) in [hscript](https://github.com/HaxeFoundation/hscript) syntax. The formula should accept a variable `n` (a numerical value) and return an integer (the plural form index). |

Rows are added for each translatable string:

| Column | Type | Description |
| ------ | ---- | ---- | ----------- |
| 1 | Integer | Resource integer ID |
| 2 | Integer, optional | Plural form index. This is for string arrays. The index should start from 0. |
| 3 | String | The text |

### Generating the catalog as resource files or embedded resource

In order to use the translations, they need to be built into a catalog. A catalog may be stored in resource files distributed beside your application, or it may be embedded using Haxe's resource system.

To import the CSV files, use `CSVLoader` in a project build script:

```haxe
var csvLoader = new CSVLoader("strings");
```

In the example, `strings` is the name used for the database that contains the catalog information. (It can be any other name if you desire.)

Next, load your CSV files:

```haxe
csvLoader.loadDirectory(
    "i18n-source/", // directory path
    true // skip the header
);
```

`i18n-source` is the directory path containing the CSV files. The CSV file contains a header row so we pass `true`.

Now the catalog has been built, we need to save the catalog somewhere. The catalog files can be saved to disk using `CatalogBuilder`:

```haxe
csvLoader.catalogBuilder.save("assets/i18n/");
```

`assets/i18n/` is the directory path containing the database that is distributed beside the executable.

Alternatively, the catalog can be embedded within the application using the Haxe resource system. When called in a macro context by `--macro`, use:

```haxe
csvLoader.catalogBuilder.embed();
```

### Loading the catalog on application start up

When your application starts up, the catalog should be loaded into the global `Translator` singleton at the `Textball` class:

```haxe
var catalog = ResourceCatalog.load("assets/i18n/", "strings");
Textball.translator.catalog = catalog;
```

If your catalog is embedded:

```haxe
var catalog = ResourceCatalog.loadResource("strings");
Textball.translator.catalog = catalog;
```

Finally, detect the requested locales from the environment:

```haxe
Textball.translator.detectLanguage();
```

The translated strings are now ready for use.

For more details about this process, see the sample application in the example directory.


## Further reading

Please see the generated [API documentation](https://chfoo.github.io/textball/api/).
