#!/usr/bin/ruby -KU
# encoding: UTF-8
#
# clipboard_extraction.rb - Extracts data from FileMaker fmxmlsnippets
#
# Author::      Donovan Chandler (mailto:donovan_c@beezwax.net)
# Copyright::   Copyright (c) 2010-2012 Donovan Chandler
# License::     Distributed under GNU General Public License <http://www.gnu.org/licenses/>
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#

base_path = File.dirname(File.dirname(__FILE__))
result_delimiter = "\n-------------\n"

$LOAD_PATH.unshift(File.expand_path(base_path) + '/resources')

require "rexml/document"
require base_path + '/lib/commands.rb'
require base_path + '/lib/filemaker.rb'
# require './lib/commands.rb'
# require './lib/filemaker.rb'
include FileMaker

tips = %Q{* You can get FileMaker objects off the clipboard more quickly using the AppleScript provided on the budnle [wiki](https://github.com/DonovanChan/filemaker.tmbundle/wiki/Getting-Clipboard-Contents-Into-TextMate).
  (You may need to copy the link and paste into your browser.)
}

# Returns readable version of exception, providing additional info if debugging is on (FileMaker::DEBUG_ON = true)
# @param [Object] Exception object
# @return [String] Readable exception message
def return_error(exception)
  if FileMaker::DEBUG_ON
    exception.message + "\n\n" + exception.backtrace.join("\n")
  else
    exception.message
  end
end

desc "Given fmxmlsnippet of layout objects, extracts all CSS."
doc %Q{
## Extract Layout Object CSS

### Description
Given an fmxmlsnippet of layout objects, extracts CSS styling for those objects.
Separates each object with string delimiter:
`-------------`
}
command :extract_css do |text|
  begin
    delim = result_delimiter
    doc = Snippet.new(text)
    doc.extract_object_css.join(delim)
  rescue => e
    puts return_error(e)
  end
end

desc "Extracts FileMaker calculations from fmxmlsnippet"
doc %Q{
## Extract Calculations

### Description
Extracts all FileMaker calculations from any fmxmlsnippet.
Delimits each calculation with '#{result_delimiter.strip}'

### Compatibility
FileMaker 7 or newer
}
command :extract_calculations do |text|
  begin
    delim = result_delimiter
    doc = Snippet.new(text)
    doc.extract_calcs.join(delim)
  rescue => e
    return_error(e)
  end
end

desc "Given fmxmlsnippet of custom functions, extracts names and parameters of FileMaker custom functions."
doc %Q{
## Extract Custom Function Names

### Description
Extracts names and parameters of custom functions from fmxmlsnippet of custom functions.
Delimits each result value with '#{result_delimiter.strip}'

### Compatibility
FileMaker 7 or newer
}
command :extract_function_names do |text|
  doc = Snippet.new(text)
  doc.extract_functions.join(result_delimiter)
end

desc "Given fmxmlsnippet of script steps, extracts text from comment steps."
doc %Q{
## Extract Script Comments

### Description
Extracts text from comment script steps from fmxmlsnippet of script steps.
Delimits each result value with '#{result_delimiter.strip}'

### Compatibility
FileMaker 7 or newer
}
command :extract_comment_text do |text|
  doc = Snippet.new(text)
  doc.extract_comment_text.join(result_delimiter)
end

desc "Compares current fmxmlsnippet document with one on clipboard, returning functions from clipboard that are not in document."
doc %Q{
## Filter Clipboard Snippet to Unique Functions

### Description
Compares current fmxmlsnippet document with one on clipboard.
Returns fmxmlsnippet containing functions from clipboard that are NOT in the current document.

### Compatibility
FileMaker 7 or newer

### Usage Instructions

1. In FILE A: Copy custom functions in FileMaker
1. Pull those functions into TextMate (using Cmd+Opt+B)
1. In FILE B: Copy custom function from another FileMaker file
1. Then run this command. It will give you the functions from FILE B that are not in FILE A.

### Tips
#{tips}
}
command :unique_functions do |snippetA,snippetB|
  begin
    # clipboard = IO.popen('pbpaste', 'r+').read

    docA = REXML::Document.new snippetA
    docB = REXML::Document.new snippetB

    def XMLToHash(rexmlDoc)
      dic = Hash.new
      rexmlDoc.elements.each("//CustomFunction") do |function|
        name = function.attributes["name"]
        text = function.to_s
        dic[name] = text
      end
      return dic
    end

    dicA = XMLToHash(docA)
    dicB = XMLToHash(docB)

    dic = Hash.new
    dicB.each do |key, value|
      unless dicA.include?(key)
        dic[key] = value
      end
    end

    snipArray = []
    dic.sort.each do |key, value|
      snipArray << value
    end
    Snippet.new(snipArray.join).to_xml
  rescue => e
    return_error(e)
  end
end


desc "Extracts custom functions from document or clipboard and saves each function to a file."
doc %Q{
## Save Functions to Files

### Description
Extracts custom functions from document or clipboard and saves each function to a file. Uses text from local file if it contains custom functions; otherwise, it looks for objects on the clipboard.

### Compatibility
FileMaker 7 or newer

### Usage Instructions

1. Copy custom functions in FileMaker
1. Ensure your current document is not empty (to prevent this help window)
1. Run this command

You can save the clipboard to a text file and run this command against it, or you can simply run it after loading the functions to your clipboard. Just make sure that the document is not empty so you don't see this help window again.

### Notes

* Currently does not support creation of directory from within dialog. So you have to create the directory before running this command.
* Depends on CocoaDialog implementation in TextMate for showing dialog. Therefore, this command is currently only suported in TextMate.
* CocoaDialog has been erratic here, so try again if it doesn't work the first time.
}
command :save_functions do |text|
  begin
    # Not using ui.rb because its implementation of fileselect didn't work
    # Instead, call directly to CocoaDialog through shell
    dPath = "#{ENV['TM_SUPPORT_PATH']}/bin/CocoaDialog.app/Contents/MacOS/CocoaDialog"

    # Settings
    ext = "calc"  # default file extension

    # Get text from file or clipboard
    unless FileMaker::Snippet.customFunction?(text)
      text = FileMaker::Clipboard.get
    end
    if text.empty?
      puts 'Unrecognized clipboard format'
      TextMate.exit_show_tool_tip
    end

    doc = REXML::Document.new text

    # Prompt for preferences
    dir = `#{dPath} fileselect \
    --title "Select directory" \
    --text "Functions will be saved to this directory" \
    --select-only-directories`
    if dir.empty? then exit end

    # Prompt for file extension
    ext = `#{dPath} inputbox \
    --title "File extension" \
    --informative-text "Enter extension for function files" \
    --text "#{ext}" \
    --button1 "OK" \
    --float`.lines.to_a[1].to_s.strip
    # ext ||= ext

    def XMLToHash(rexmlDoc)
      dic = Hash.new
      rexmlDoc.elements.each("//CustomFunction") do |function|
        name = function.attributes["name"]
        text = function.elements["Calculation"].text
        dic[name] = text
      end
      return dic
    end

    dic = XMLToHash(doc)
    dic.each do |key, value|
      File.open("#{dir.rstrip}/#{key}.#{ext}", 'w') {|f| f.write(value)}
    end
    TextMate.exit_show_html "<h2>Save Custom Functions to Files</h2><h4>Files saved to following directory:</h4><p>#{dir}</p>"

  rescue => e
    return_error(e)
  end
end