(*
NAME:
	PasteSnippet (v2.0)
	
PURPOSE:
	Loads fmxmlsnippet onto pasteboard in proper format for pasting into FileMaker.

PARAMETERS:
	1	Path to xml file being placed on pasteboard

HISTORY:
	Created 2011.03.23 by Donovan Chandler, donovan_c@beezwax.net
	Modified 2011.12.17 by Donovan Chandler: Converts placeholders for high ascii characters
	Modified 2012.04.03 by Donovan Chandler: Added support for XML2 format (in FM 12)
	Modified 2012.06.01 by Donovan Chandler: Reports errors from xmllint

NOTES:
	This script is intended to be called using a command from the shell like this: osascript PasteSnippet.applescript "$XML_TEXT"
*)
------------------------------------------------

on run argv
	---- Parameters ----
	--set clipAlias to (item 1 of argv) as POSIX file
	set clipText to (item 1 of argv)
	if clipText is equal to "" then return "Error: Missing text"
	
	---- Settings ----
	-- Format of FileMaker object in clip [script|script_step|table|field|custom_function]
	set clipClass to determineClass(clipText)
	if clipClass begins with "Error" then return clipClass
	
	------------------------------------------------
	---- Strip leading blank lines ----
	set clipText to trim(clipText, character id 10, 0)
	
	------------------------------------------------
	---- Restore extended ASCII characters
	-- Calling this script through bash replaces high ascii characters
	-- with a placeholder (e.g., space => "#:20:#")
	set clipText to restoreExtendedASCII(clipText, "#:", ":#")
	
	------------------------------------------------
	---- Escape single quotes for shell
	----	Could possibly use xargs -0 for this, if it works with xmllint
	set clipText to searchReplaceText(clipText, "'\\''", "'")
	set clipText to searchReplaceText(clipText, "'", "'\\''")
	
	------------------------------------------------
	---- Validate XML ----
	try
		set clipText to do shell script "echo '" & clipText & "' | xmllint -"
	on error errMsg number errNum
		return "Error validating XML: " & errMsg
	end
	
	---- Convert clip to proper class ----
	set clipTextFormatted to convertClip(clipText, clipClass)
	
	---- Load to clipboard ----
	try
		set the clipboard to clipTextFormatted
		return "Snippet copied to clipboard"
	on error errMsg number errNum
		return "Error: " & errNum & ": " & errMsg
		--return "Error: Unrecognized format"
	end try
end run

------------------------------------------------
--  HANDLERS
------------------------------------------------

-- HANDLER: Converts xml text to FileMaker clipboard format
-- Parameters: clipText, outputClass [script|script_step|table|field|custom_function]
-- Methodology: Write text to temp file so that it can be converted from file
-- Formats:
--	XMSC for script definitions
--	XMSS for script steps
--	XMTB for table definitions
--	XMFD for field definitions
--	XMCF for custom functions
--	XML2 for layout objects in FileMaker 12
--	XMLO for layout objects in FileMaker 7-11
on convertClip(clipText, outputClass)
	set temp_path to (path to temporary items as Unicode text) & "FMClip.dat"
	set temp_ref to open for access file temp_path with write permission
	set eof temp_ref to 0
	write clipText to temp_ref as «class utf8»
	close access temp_ref
	if outputClass is "XMSC" then
		set clipTextFormatted to read file temp_path as «class XMSC»
	else if outputClass is "XMSS" then
		set clipTextFormatted to read file temp_path as «class XMSS»
	else if outputClass is "XMTB" then
		set clipTextFormatted to read file temp_path as «class XMTB»
	else if outputClass is "XMFD" then
		set clipTextFormatted to read file temp_path as «class XMFD»
	else if outputClass is "XMFN" then
		set clipTextFormatted to read file temp_path as «class XMFN»
	else if outputClass is "XML2" then
		set clipTextFormatted to read file temp_path as «class XML2»
	else if outputClass is "XMLO" then
		set clipTextFormatted to read file temp_path as «class XMLO»
	else
		return "Error: Snippet class not recognized"
	end if
	return clipTextFormatted
end convertClip

-- HANDLER: Determines FileMaker pasteboard class of xml text
-- Formats:
--	XMSC for script definitions
--	XMSS for script steps
--	XMTB for table definitions
--	XMFD for field definitions
--	XMCF for custom functions
--	XML2 for layout objects in FileMaker 12
--	XMLO for layout objects in FileMaker 7-11
on determineClass(clipText)
	try
		set clipText to searchReplaceText(clipText, "<?", "?")
		set array to my split(clipText, "<")
		set child1 to item 3 of array
	on error errMsg number errNum
		--return "Error: " & errNum & ": " & errMsg
		return "Error: Unrecognized format"
	end try
	if child1 starts with "Script" then
		set theClass to "XMSC"
	else if child1 starts with "Step" then
		set theClass to "XMSS"
	else if child1 starts with "BaseTable" then
		set theClass to "XMTB"
	else if child1 starts with "Field" then
		set theClass to "XMFD"
	else if child1 starts with "CustomFunction" then
		set theClass to "XMFN"
	else if ((offset of "<LocalCSS" in clipText) > 0) then
		set theClass to "XML2"
	else if child1 starts with "Layout" then
		set theClass to "XMLO"
	else
		return "Error: Snippet format not recognized"
	end if
	return theClass
end determineClass

-- HANDLER: Returns patterncount
on patternCount(theText, matchString)
	set oldTID to AppleScript's text item delimiters
	set AppleScript's text item delimiters to {matchString}
	set countedPattern to count of text items of theText
	set AppleScript's text item delimiters to oldTID
	return countedPattern - 1
end patternCount

-- HANDLER: Returns text from file.  Prompts for file if no alias specified.
on readFile(fileAlias)
	if fileAlias = "" then
		set theFile to choose file with prompt (localized string "chooseFile")
	else
		set theFile to fileAlias
	end if
	try
		open for access theFile
		set fileText to (read theFile)
		close access theFile
		return fileText
	on error errMsg number errNum
		try
			close access theFile
		end try
		return "Error: " & errNum & ": " & errMsg
	end try
end readFile

-- HANDLER: Replaces placeholders set by calling bash script
--	Allows bash script to pass extended ascii characters
--	Requires handlers: searchReplaceText, textBetween
on restoreExtendedASCII(theText, tagStart, tagEnd)
	set num to my textBetween(theText, tagStart, tagEnd)
	repeat while (num > 0)
		set char to character id num
		set theText to my searchReplaceText(theText, tagStart & num & tagEnd, char)
		set num to my textBetween(theText, tagStart, tagEnd)
	end repeat
	return theText
end restoreExtendedASCII

-- HANDLER: Searches and replaces string within text block
--	Accepts lists in searchString and replaceString
to searchReplaceText(theText, searchString, replaceString)
	set searchString to searchString as list
	set replaceString to replaceString as list
	set theText to theText as text
	
	set oldTID to AppleScript's text item delimiters
	repeat with i from 1 to count searchString
		set AppleScript's text item delimiters to searchString's item i
		set theText to theText's text items
		set AppleScript's text item delimiters to replaceString's item i
		set theText to theText as text
	end repeat
	set AppleScript's text item delimiters to oldTID
	
	return theText
end searchReplaceText

-- HANDLER: Splits string into array by delimiter
to split(someText, delimiter)
	set AppleScript's text item delimiters to delimiter
	set someText to someText's text items
	set AppleScript's text item delimiters to {""}
	return someText
end split

-- HANDLER: Returns text between first occurrences of openDelim and closeDelim
on textBetween(theText, openDelim, closeDelim)
	set oStart to offset of openDelim in theText
	if oStart = 0 then return ""
	set oStart to oStart + (length of openDelim)
	set oEnd to offset of closeDelim in (text (oStart + 1) thru (length of theText) of theText)
	if oEnd = 0 then return ""
	set oEnd to oEnd + oStart - 1
	set result to text oStart thru oEnd of theText
end textBetween

--Handler: Remove trailing and/or leading characters from strings
on trim(this_text, trim_chars, trim_indicator)
	-- 0 = beginning, 1 = end, 2 = both
	set x to the length of the trim_chars
	-- TRIM BEGINNING
	if the trim_indicator is in {0, 2} then
		repeat while this_text begins with the trim_chars
			try
				set this_text to characters (x + 1) thru -1 of this_text as string
			on error
				-- the text contains nothing but the trim characters
				return ""
			end try
		end repeat
	end if
	-- TRIM ENDING
	if the trim_indicator is in {1, 2} then
		repeat while this_text ends with the trim_chars
			try
				set this_text to characters 1 thru -(x + 1) of this_text as string
			on error
				-- the text contains nothing but the trim characters
				return ""
			end try
		end repeat
	end if
	return this_text
end trim