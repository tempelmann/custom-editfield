# custom-editfield
Automatically exported from code.google.com/p/custom-editfield

The CustomEditField is a set of classes that are primarily designed to display source code and similar structured text, such as XML. It is ideal to show and edit Xojo / REALbasic (RbScript) code, for instance.

It comes with examples for performing a "diff" on two adjacent texts, and for using its syntax highlighting engine with other types of edit fields.

Caution: When using this code in a Mac Cocoa app, text input with dead keys (e.g. by first pressing the ^ key, then a vovel key) will not work. To fix this, this code would need to use Xojo's TextInputCanvas plugin (https://github.com/xojo/TextInputCanvas), which it currently doesn't do.

Note: If you need a more complete word processing solution that provides several different editor types then check out the "Formatted Text Control" (http://www.bkeeney.com/formatted-text-control) from BKeeney Software Inc.

Features:
 * Syntax Highlighting
 * Line auto-indenting (some problems, see Issues tracker)
 * Autocomplete
 * Line numbering
 * Invisible characters
 * Undo
 * Line Foldings (currently not fully working, see Issues tracker)
 * Find/Replace
 * Printing
 * Bookmarks
 * Placeholders

The project runs as a demo, showing off many of its features:

![cef-demo](https://cloud.githubusercontent.com/assets/461920/7630988/929d2024-fa3c-11e4-82bb-c78ba6242609.png)
