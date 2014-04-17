# TextMate bundle for FileMaker Pro

## Introduction

Provides syntax highlighting, code snippets, quick documentation reference and robust code generating commands. You can even interact directly with FileMaker Pro's clipboard from within this bundle.

This project was forked from a simpler version by Matt Petrowsky. His bundle was a simplification of the original bundle by Charles Ross. My version mostly adds to the commands.

For more information, please see the help file. You can access that in the bundle menu or in the support folder.

**Sublime Text** users, see my [FileMaker](https://github.com/DonovanChan/FileMaker) project instead.

## Features

* Tab triggers for FileMaker functions
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
* Code folding
* Help section
* Full documention on most commands (displayed when running command with empty input)

## Installing

### For easy installation

1. Install [TextMate](http://macromates.com/)
1. Download these files. ([zip](http://github.com/DonovanChan/filemaker.tmbundle/zipball/master) and [tar](http://github.com/DonovanChan/filemaker.tmbundle/tarball/master) formats available)
1. Uncompress/extract the package contents, if necessary.
1. Rename the folder to "FileMaker.tmbundle". (You will have to remove some metadata from the name.)
1. Double-click on the file.

That's it! TextMate will install the bundle  automatically into "~/Library/ApplicationSupport/TextMate/Bundles"

### For easy upgrades

You can set up the bundle as a [Git](http://git-scm.com) repository right where TextMate installs it. Just copy the appropriate commands below into your Terminal.

**TextMate 1**

```
mkdir -p ~/Library/Application\ Support/TextMate/Bundles
cd ~/Library/Application\ Support/TextMate/Bundles
git clone git://github.com/DonovanChan/filemaker.tmbundle.git "FileMaker.tmbundle"
osascript -e 'tell app "TextMate" to reload bundles'
```


**TextMate 2**

```
mkdir -p ~/Library/Application\ Support/Avian/Bundles
cd ~/Library/Application\ Support/Avian/Bundles
git clone git://github.com/DonovanChan/filemaker.tmbundle.git "FileMaker.tmbundle"
```

## Updating

If you simply downloaded the zip files, you'll need to download and move them again. If you cloned the repository, you can pull down the latest updates like this:

**TextMate 1**

```
# Update FileMaker bundle for TextMate 1
cd ~/Library/Application\ Support/TextMate/Bundles/filemaker.tmbundle
git pull
```

**TextMate 2**

```
# Update FileMaker bundle for TextMate 2
cd ~/Library/Application\ Support/Avian/Bundles/filemaker.tmbundle
git pull
```

## License

See license.txt

## Contact

Donovan Chandler  
Beezwax Datatools, Inc.  
donovan_c@beezwax.net  

## History

Original bundle by Charles Ross, puvinyel@znp.pbz  
Forked 3/12/11 by Donovan Chandler from Matt Petrowsky
