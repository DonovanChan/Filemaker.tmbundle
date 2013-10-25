#!/System/Library/Frameworks/Ruby.framework/Versions/1.8/usr/bin/ruby -KU
# encoding: UTF-8
#
# clipboard_generation.rb - Builds FileMaker fmxmlsnippets
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

$LOAD_PATH.unshift(File.expand_path(base_path) + '/resources')

require base_path + '/lib/commands.rb'
require base_path + '/lib/filemaker.rb'
# require './lib/commands.rb'
# require './lib/filemaker.rb'
include FileMaker

tips = %Q{* Example arrays create objects compatible with Contact Management FMP11 starter solution.
* The resulting XML is more readable if the current document is set to the "FileMaker Clipboard" language.
* Press Cmd-B to load the current document or selected text onto the FileMaker clipboard. Only works if language is set to "FileMaker Clipboard."
* Press Cmd-Ctl-T to access commands easier.
* Optional values can be empty, even if you have tabs extending out to other columns on the right.}

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

desc "Uses tabular array to generate fmxmlsnippet of FileMaker field layout objects"
doc %Q{
## Array to Layout Fields (Pre-FileMaker 12)

### Description
Generates FileMaker snippet of field layout objects (to be pasted onto any layout).
Uses selected text or entire document.

Does not work in FileMaker 12 or newer.

### Example Usage
Copy the lines below into a document and run the command again to see it work.

~~~~
Contact::Name_First\t"Name of person"\tVerdana\t12\tfield_nameFirst
Contact::Name_Last\tSelf\tHelvetica\t14
~~~~

### Parameters

| Column  | Definition    | Default Value | Required? |
|:--------|:--------------|:--------------|:----------|
| 1 | fully qualified field name  | | Yes |
| 2 | tooltip  | | No |
| 3 | font  | | No |
| 4 | fontSize  | | No |
| 5 | objectName  | | No |

### Tips
#{tips}
}
command :array_to_layout_fields_11 do |paramArray|
  begin
    doc = Snippet::Pre12.new
    paramArray.split(/\n/).each { |row|
    	col = row.split(/\t/)
    	arg = {
    		:fieldQualified  => col[0],
    		:tooltip         => col[1],
    		:font            => col[2],
    		:fontSize        => col[3],
    		:objectName      => col[4],
    		:fieldHeight     => 18,
    		:fieldWidth      => 120,
    		:verticalSpacing => 20
    	}
    	doc.layoutField(arg)
    }
    doc
  rescue => e
    puts return_error(e)
  end
end

# TODO Add parameter for label font and size or couple with field options.
desc ""
doc %Q{
## Array to Layout Fields Labeled (Pre-FileMaker 12)

### Description
Generates FileMaker snippet of field layout objects (to be pasted onto any layout).
Each field is pasted along with label specified in array.
Uses selected text or entire document.

Does not work in FileMaker 12 or newer.

### Example Usage
Copy the lines below into a document and run the command again to see it work.

~~~~
Contact::Name_First\tFirst Name\tSelf\tMonaco\t12\tfield_nameFirst
Contact::g_HiliteLibrary[2]\tGlobal\t"Contains highlight"
~~~~

### Parameters

| Column  | Definition    | Default Value | Required? |
|:--------|:--------------|:--------------|:----------|
| 1 | fully qualified field name  | | No  |
| 2	| field label	| | Yes	|
| 3	| tooltip	| | Yes	|
| 4	| font	| | Yes	|
| 5	| fontSize  | | Yes	|
| 6	| objectName	| | Yes	|
}
command :array_to_layout_fields_labeled_11 do |paramArray|
  begin
    doc = Snippet::Pre12.new
    paramArray.split(/\n/).each { |row|
    	col = row.split(/\t/)
    	fieldOpt = {
    		:fieldQualified  => col[0],
    		:tooltip         => col[2],
    		:font            => col[3],
    		:fontSize        => col[4],
    		:objectName      => col[5],
    		:fieldHeight     => 18,
    		:fieldWidth      => 120,
    		:verticalSpacing => 20
    	}
    	labelText = col[1] || FileMaker::Calc.field_name(col[0])
    	doc.layoutFieldWithLabel(fieldOpt,labelText)
    }
    doc
  rescue => e
    puts return_error(e)
  end
end