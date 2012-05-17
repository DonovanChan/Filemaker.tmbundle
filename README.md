# TextMate bundle for FileMaker Pro

## Introduction

This is an adaptation of the TextMate Bundle for FileMaker Pro for use in Sublime Text 2.

Provides syntax highlighting and code snippets. Other functionality relating to commands are not available for Sublime Text.

This project was forked from a simpler version by Matt Petrowsky.  His bundle was a simplification of the original bundle by Charles Ross. My version mostly adds to the commands.

## Installation

### For easy installation

1. Download these files. (You should see a giant "Downloads" button on the top-right.)
1. Extract the .zip contents if necessary.
1. Change the name of the folder to "FileMaker.tmbundle". (You will have to remove some metadata from the name.)
1. Double-click on the file.

That's it! TextMate will install the bundle automatically into "~/Library/ApplicationSupport/TextMate/Bundles"

### For easy upgrades

You can set up the bundle as a git repository right where TextMate installs it. Here are the Terminal commands:

	mkdir -p ~/Library/Application\ Support/TextMate/Bundles
	cd ~/Library/Application\ Support/TextMate/Bundles
	git clone git://github.com/DonovanChan/filemaker.tmbundle.git -b SublimeText2 "FileMaker.tmbundle"
	osascript -e 'tell app "TextMate" to reload bundles'

The TextMate 2 pre-release stores bundles in a different place, however:

	mkdir -p ~/Library/Application\ Support/Avian/Bundles
	cd ~/Library/Application\ Support/Avian/Bundles
	git clone git://github.com/DonovanChan/filemaker.tmbundle.git -b SublimeText2 "FileMaker.tmbundle"

## History

Original bundle by Charles Ross, puvinyel@znp.pbz

Forked 3/12/11 by Donovan Chandler from Matt Petrowsky

## License

Copyright 2012  Donovan Chandler, Beezwax Datatools
donovan_c@beezwax.net

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.
