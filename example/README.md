Example
=======

This example shows how to write the CSV files, embed them using Haxe's resource embedding system, and load it during application start up.

The CSV files are located in the `csv` directory.

The main hxml build file is `example.hxml`:

    haxe example.hxml -js example.js

For convenience, some target files are provided:

    haxe hxml/example.cpp.hxml
    haxe hxml/example.js.hxml
    haxe hxml/example.neko.hxml

Run the application:

    ./out/cpp/Example
    neko out/neko/example.n
