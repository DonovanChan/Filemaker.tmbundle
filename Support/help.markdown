# Introduction

This bundle provides tools for developing solutions in FileMaker Pro (a proprietary RDBMS). It provides basic features like syntax highlighting and tab triggers for calcuations. But it goes much deeper, allowing you to generate code and even interact directly with FileMaker objects on your clipboard.

# Features

* Tab triggers for FileMaker's functions
* Documentation for functions, script steps and error codes
* Commands
	* Manipulating/generating calculations
	* Manipulating/generating FileMaker clipboard XML
	* Extracting data from the DDR
	* Extracting data from import.log files
* Syntax highlighting
	* FileMaker
	* FileMaker Clipboard
	* FileMaker Log
	* FileMaker Hash (Generated using #( ) custom function)
* Code folding

## Tab Triggers

Tab triggers exist for every native FileMaker function. Templates are included for function parameters to allow you to tab through them. To discover or modify the abbreviated tab triggers, find the function in the FileMaker bundle menu (Bundles>FileMaker>[Function Category]>[Function Name]). You can also search for them by pressing ⌘^T.

Keyword shorthand versions of words:

<table>
	<tr><th>Word</th><th>Shortcut</th></tr>
	<tr><td>record</td><td>rec</td></tr>
	<tr><td>number</td><td>num</td></tr>
	<tr><td>summary</td><td>sum</td></tr>
	<tr><td>timestamp</td><td>ts</td></tr>
	<tr><td>evaluate</td><td>eval</td></tr>
	<tr><td>object</td><td>ob</td></tr>
	<tr><td>value(s)</td><td>val</td></tr>
</table>

For example, typing "leftval" will expand to "LeftValues ( template1 ; template2 )"

Previous incarnations of the bundle included snippets for things like the PHP API, SmartPill PHP and zippScript. If you would like any of those added. Let us know via email or, preferably, by submitting an issue on the github page.

## Documentation Lookup

Place your cursor on a work and press ^H to search for related documentation. Documentation is provided for the following:

* Functions (native, fmsauc, SimpleDialog, SuperContainer)
* Script steps
* Error codes (including AppleScript errors)

A search window will appear if no entries are found.

## Commands

Functions are organized according to the type of text being worked with.

Commands postfixed with "**" do not work.
Commands postfixed with "*" are incomplete but functional.

### Calculations

### Calculation Generation

Allows you to programmatically write code using simpler arrays and lists. Here's an example you might use if you were using transactions and were writing values from global fields to local fields:

1. Create first column (target field names)
	* Type in names of fields
	* Extract list of field names (using other command)
1. Create second column (values)
	* Type in values
	* Generate field names from first column (using regular expression or shell script)
1. Run "Build Set Field Steps" command
1. Paste new script steps into FileMaker
	* See following section, Clipboard, for more details

### Clipboard

Handles XML text extracted from the FileMaker clipboard. There are two central commands for this functionality:

<table>
	<tr><th>Shortcut</th><th>Name</th><th>Action</th></tr>
	<tr><td>⌘+Opt+b</td><td>Get Snippet From Clipboard</td><td>Opens FileMaker clipboard contents as new XML document</td></tr>
	<tr><td>⌘+b</td><td>Load Snippet to Clipboard</td><td>Loads current XML document to FileMaker's clipboard as snippet</td></tr>
</table>

Note, you must have the current XML document assigned to the FileMaker Clipboard language in order to use these shortcuts.

#### Clipboard Manipulation Utilities

There are several utilities available to help you manipulate the clipboard:

* AppleScript (takes some knowhow)
* fmClipboardBroker (free!)
* bBox plug-in (free!)
* Clip Manager (excellent, full-featured utility)
* ScriptMaster Advanced (allows access to FileMaker clipboard)

### DDR

Helps you extract specific information from the DDR.

### Logs

Helps you extract specific information from FileMaker's import log files, which describe your paste and import actions.

# Preferences

Preferences will favor conventions adopted by the FOCUS Framework at Beezwax.

# Syntax Highlighting

Provided for the following formats:

* FileMaker
* FileMaker Clipboard
	* Basically XML, but it should provide highlighting for FileMaker syntax within that XML
* FileMaker Log
	* Very basic, but those logs can be very difficult to read without it!
* FileMaker Hash
	* For dictionaries generated using custom function suite from [six.fried.rice](http://sixfriedrice.com/wp/filemaker-dictionary-functions/). [FOCUS](http://focus.beezwax.net/groups/focus) makes extensive use of this hash format. A full suite of functions are vailable on github [here](https://github.com/beezwax/FOCUS/tree/master/Functions)

# Usage Tips

## To open calculations in TextMate faster

I find copy/paste sufficient, but you may have higher ambitions. Here are some ideas:

* Use QuickKeys to quickly copy your dialog content to a temporary text file opened in TextMate
* Trigger a shell script or AppleScript using TextExpander
* TextMate provides some functionality for this use case, but I have not looked to see if FileMaker supports it

## Becoming a power user

### Read a tutorial

Here's a good place to start: [TextMate Tutorials and More](http://projects.serenity.de/textmate/tutorials/basics/) By Stanley Rost (maintainer of TODO bundle)

### Learn which commands are available to you

Other bundles, or maybe even this one, may have many useful commands you have not noticed before. You can easily find what's available to you by browsing the menu's. Even easier, try selecting something and pressing ^ ⌘T to show the Budles > Select Bundle Item... menu option.

### Learn to manipulate text

Manipulating text can make your development much more efficient. Sometimes the power trip can also provide a thrill in itself!  Learning to use tools like shell scripts — grep, sed, awk — will give you many returns. You can run one-off scripts against your documents using the menu option Text > Filter Through Command.

## To create your own commands or customizations

Look in the help docs to get started. To peruse the bundle contents, open the Bundle Editor by selecting Bundles > Bundle Editor > Show Bundle Editor.

TextMate supports multiple languages: shell scripts, Ruby, Python. I've found that Ruby has some great resources for learning and is very easy to practice. You can test it out using irb in Terminal or run your scripts from within TextMate.

You can customize the bundle and then update it without losing your customizations. TextMate will store your updates in ~/Library/Application Support/TextMate/Bundles. It will store the installed/updated copy of the bundle in ~/Library/Application Support/TextMate/Pristine Copy/Bundles.

# FAQ

### Why don't the snippets expand for me?

Many of the bundle snippets are bound to a certain language. Check that the language for your current document is set to "FileMaker". Do this by selecting from the languages available in the left-hand side of the footer bar.

### Why are the FileMaker bundle commands grayed out?

Many of the bundle commands are bound to a certain language. Check that the language for your current document is set appropriately — either "FileMaker", "FileMaker Clipboard", etc. Do this by selecting from the languages available in the left-hand side of the footer bar.

### The snippets aren't formatted the way I want. How do I change them?

Open the Bundle Editor and edit the snippets from there. Please see "To create your own commands and customizations" section above. If you know regular expressions, you can also modify the Tidy command instead of updating every snippet.

### How do I change or add new commands?

You can always request features on [github](https://github.com/DonovanChan/filemaker.tmbundle/issues "github issues page") (see "How to Report Bugs or Request Features" below), but it's much more empowering to learn it yourself! Open the Bundle Editor and edit the commands from there. Please see "To create your own commands and customizations" section above.

### How do I get involved in improving this bundle?

I thought you'd never ask! There's several ways to get involved:

* Submit new issues on [github](https://github.com/DonovanChan/filemaker.tmbundle/issues "github issues page")
* Send me a pull request on github
* Email me at [donovan_c@beezwax.net](mailto:donovan_c@beezwax.net)

# Known Bugs

* Function snippets are not loading to the clipboard

# How to Report Bugs or Request Features

Issues are being tracked on github [here](https://github.com/DonovanChan/filemaker.tmbundle/issues "github issues page"). 

# History

(As far as I can deduce.)

Original bundle by [Charles Ross](http://code.google.com/p/filemaker-textmate-bundle/)
Bundle modified at some point by Jonathan Stark.
Next incarnation by [Matt Petrowsky](http://github.com/petrowsky) (simplified version)  
Forked 3/12/11 from Matt by Donovan Chandler (added commands and additional languages)

Source available on [GitHub](https://github.com/DonovanChan/filemaker.tmbundle)

This file has been modifed from its states when forked from Charles Ross and Matt Petrowsky.

# License

This bundle is licensed under the Apache 2.0 license in an attempt to conform to the license used by Charles Ross in the original bundle. This license requires that files include comments indicating any modifications. I did my best with the comments, but TextMate is not very friendly in that regard.

# Contact

Donovan Chandler  
Beezwax Datatools, Inc. 
donovan_c@beezwax.net
