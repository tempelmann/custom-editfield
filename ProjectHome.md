The CustomEditField is a set of classes that are primarily designed to display source code and similar structured text, such as XML. It is ideal to show and edit Xojo / REALbasic (RbScript) code, for instance.

It comes with examples for performing a "diff" on two adjacent texts, and for using its syntax highlighting engine with other types of edit fields.

**Caution:** When using this code in a Mac Cocoa app, text input with dead keys (e.g. by first pressing the ^ key, then a vovel key) will not work. To fix this, this code would need to use Xojo's [TextInputCanvas plugin](https://github.com/xojo/TextInputCanvas), which it currently doesn't.

**Note:** If you need a more complete word processing solution that provides several different editor types then check out the ["Formatted Text Control"](http://www.bkeeney.com/formatted-text-control/) from BKeeney Software Inc. Another solution might be Alfred Van Hoek's [Lexing](http://vanhoekplugins.com/REALStudio/Lexing.html) and [WordGuide](http://vanhoekplugins.com/REALStudio/WordGuise.html) plugins.

**To download the source, you need to use a svn client, as Google has stopped proving zip files via the Downloads section!**

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