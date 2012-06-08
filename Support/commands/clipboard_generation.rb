#!/usr/bin/env ruby -KU
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

tips = %Q{* Example arrays create objects compatible with Contacts FMP12 starter solution.
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

desc "Uses tabular array to generate fmxmlsnippet of FileMaker fields"
doc %Q{
## Array to Fields

### Description
Generates FileMaker snippet of Fields (to be pasted into any table).  
Uses selected text or entire document.  

### Example Usage
Copy the lines below into a document and run the command again to see it work.

~~~~
Name_First
Name_Last
Global	Number	True	Comment for field	10
Name_FL	Text	False	E.g., John Smith	1	Contact::Name_First & Contact::Name_Last
~~~~

### Parameters

| Column  | Definition    | Default Value | Required? |
|:--------|:--------------|:--------------|:----------|
| 1 | field name (Fully qualified) | | Yes  |
| 2 | field type | Text  | No |
| 3 | is global? (Boolean) | False  | No  |
| 4 | comment | | | No  |
| 5 | max repetitions | 1 | No |
| 6 | calculation | | No |

### Tips
#{tips}
}
command :array_to_fields do |paramArray|
  begin
    doc = Snippet.new
    paramArray.split(/\n/).each do |row|
      col = row.split(/\t/)
      name = col[0]
      arg = {
        :type        => col[1],
        :isGlobal    => col[2] || false,
        :comment     => col[3],
        :repetitions => col[4],
        :calculation => col[5]
      }
      doc.field(name,arg)
    end
    doc.to_xml
  rescue => e
    puts return_error(e)
  end
end

desc "Uses tabular array to generate fmxmlsnippet of FileMaker field layout objects"
doc %Q{
## Array to Layout Fields

### Description
Generates FileMaker snippet of field layout objects (to be pasted onto any layout).  
Uses selected text or entire document.  

### Compatibility
FileMaker 12 or newer

### Example Usage
Copy the lines below into a document and run the command again to see it work.

~~~~
Contacts::Company\t"Website: " & Contacts::Website\tMonaco\t12pt\tfield_company
Contacts::Title\tSelf\tHelvetica\t14pt
~~~~

### Parameters

| Column  | Definition    | Default Value | Required? |
|:--------|:--------------|:--------------|:----------|
| 1 | fully qualified field name  | | Yes |
| 2 | tooltip  | | No |
| 3 | font  | | No |
| 4 | fontSize  | | No |
| 5 | objectName  | | No |
| 6 | fieldHeight | fontSize + 10 | No |
| 7 | fieldWidth | 120 | No |
| 8 | verticalSpacing | 20 | No |

### Tips
#{tips}
}
command :array_to_layout_fields do |paramArray|
  begin
    doc = Snippet.new
    paramArray.split(/\n/).each { |row|
      col = row.split(/\t/)
      arg = {
        :fieldQualified  => col[0],
        :tooltip         => col[1],
        :font            => col[2],
        :fontSize        => col[3],
        :objectName      => col[4],
        :fieldHeight     => col[5],
        :fieldWidth      => col[6] || 120,
        :verticalSpacing => col[7] || 20
      }
      doc.layoutField(arg)
    }
    doc
  rescue => e
    puts return_error(e)
  end
end

desc "Uses tabular array to generate fmxmlsnippet of FileMaker field layout objects with text labels"
doc %Q{
## Array to Layout Fields Labeled

### Description
Generates FileMaker snippet of field layout objects (to be pasted onto any layout).  
Each field is pasted along with label specified in array.  
Uses selected text or entire document.  

### Compatibility
FileMaker 12 or newer

### Example Usage
Copy the lines below into a document and run the command again to see it work.

~~~~
Contacts::Company\tCompany Name\t"Website: " & Contacts::Website\tMonaco\t12pt\tfield_company
Contacts::Title\t\tSelf\tHelvetica\t14pt
~~~~

### Parameters

| Column  | Definition    | Default Value | Required? |
|:--------|:--------------|:--------------|:----------|
| 1 | fully qualified field name  | | Yes  |
| 2	| field label	| field name from col 1 | No	|
| 3	| tooltip	| | No	|
| 4	| font	| | No	|
| 5	| fontSize  | | No	|
| 6	| objectName	| | No	|
}
command :array_to_layout_fields_labeled do |paramArray|
  begin
    doc = Snippet.new
    paramArray.split(/\n/).each do |row|
      col = row.split(/\t/)
      fontSize = col[4]
      fieldHeight = fontSize ? fontSize.to_i + 10 : 22
      fieldOpt = {
        :fieldQualified  => col[0],
        :tooltip         => col[2],
        :font            => col[3],
        :fontSize        => fontSize,
        :objectName      => col[5],
        :fieldHeight     => fieldHeight,
        :fieldWidth      => 120,
        :verticalSpacing => fieldHeight
      }
      labelText = col[1]
      labelText = FileMaker::Calc.field_name(col[0]) if labelText.nil? || labelText.empty?
      doc.layoutFieldWithLabel(fieldOpt,labelText)
    end
    doc
  rescue => e
    return_error(e)
  end
end

desc "Uses tabular array to generate fmxmlsnippet of FileMaker field layout objects with optional Perform Script button action"
doc %Q{
## Array to Layout Field Buttons

### Description
Generates FileMaker snippet of field layout objects (to be pasted onto any layout).  
Each field is pasted with an optional Perform Script button action.  
Uses selected text or entire document.  

### Compatibility
FileMaker 12 or newer

### Example Usage
Copy the lines below into a document and run the command again to see it work.

~~~~
Contacts::Company\t"Website: " & Contacts::Website\tMonaco\t12pt\tfield_company\t40\t20\t-1\t86
Contacts::Title\tSelf\tHelvetica\t14pt\t\t\t\t-1\t146\t"Param not needed"
~~~~

### Parameters

| Column  | Definition    | Default Value | Required? | Comments |
|:--------|:--------------|:--------------|:----------|:---------|
| 1 | fully qualified field name  | | Yes | |
| 2 | tooltip  | | No | |
| 3 | font  | | No | |
| 4 | fontSize  | | No | |
| 5 | objectName  | | No | |
| 6 | fieldHeight | fontSize + 10pt or 22pt | No | |
| 7 | fieldWidth  | 120 | No | |
| 8 | marginTop | | No | |
| 9 | script id | | No | Inspect fmxmlsnippet of the script itself. ID is in the "id" attribute of the "Script" element. |
| 10 | script parameter | | No | |
}
command :array_to_layout_field_buttons do |paramArray|
  begin
    doc = Snippet.new
    paramArray.split(/\n/).each do |row|
      col = row.split(/\t/)
      fontSize = col[3]
      fieldHeight = fontSize ? fontSize.to_i + 10 : 22
      fieldOpt = {
        :fieldQualified   => col[0],
        :tooltip          => col[1],
        :font             => col[2],
        :fontSize         => fontSize,
        :objectName       => col[4],
        :fieldHeight      => col[5] || fieldHeight,
        :fieldWidth       => col[6] || 120,
        :marginTop        => col[7],
        :scriptID         => col[8],
        :scriptParam      => col[9],
      }
      doc.layoutFieldButton(fieldOpt)
    end
    doc
  rescue => e
    return_error(e)
  end
end

desc "Uses tabular array to generate fmxmlsnippet of FileMaker Set Field script steps"
doc %Q{
## Array to Set Field Script Steps

### Description
Generates FileMaker snippet of Set Field script steps.
Uses selected text or entire document.

### Compatibility
FileMaker 7 or newer

### Example Usage
Copy the lines below into a document and run the command again to see it work.

~~~~
Contact::Company\t"Beez" & "wax"
Contact\tTitle\t"Flinstone"\t$_rep
~~~~

### Parameters

#### Usage A

| Column  | Definition    | Default Value | Required? |
|:--------|:--------------|:--------------|:----------|
| 1 | table name  | | Yes  |
| 2	| field name	| | Yes	|
| 3	| field value	| | No	|
| 4	| field repetition	| | No	|

#### Usage B

| Column  | Definition    | Default Value | Required? |
|:--------|:--------------|:--------------|:----------|
| 1 | table::field  | | Yes  |
| 2	| field value	| | No	|
| 3	| field repetition	| | No	|

### Tips
#{tips}
  
}
command :array_to_set_field do |paramArray|
  begin
    doc = Snippet.new
    paramArray.split(/\n/).each { |row|
      col = row.split(/\t/)
      if not col[0].include?("::")
        col[0] = col[0] + '::' + col[1]
        col.slice!(1)
      end
      arg = {
        :fieldQualified	=> col[0],
        :calculation		=> col[1],
        :repetition		=> col[2]
      }
      doc.stepSetField(arg)
    }
    doc.to_xml
  rescue => e
    return_error(e)
  end
end

desc "Uses tabular array to generate fmxmlsnippet of FileMaker Set Variable script steps"
doc %Q{
## Array to Set Variable Script Steps

### Description
Generates FileMaker snippet of Set Variable script steps.
Uses selected text or entire document.

### Compatibility
FileMaker 7 or newer

### Example Usage
Copy the lines below into a document and run the command again to see it work.

~~~~
$_local\tGet ( AccountName )
$$_global\t"CONTACT"\t23
~~~~

### Parameters

| Column  | Definition    | Default Value | Required? |
|:--------|:--------------|:--------------|:----------|
| 1 | variable name | | Yes |
| 2 | value calculation | | No  |
| 3 | variable repetition | | No |

### Tips
#{tips}
}
command :array_to_set_variable do |paramArray|
  begin
    doc = Snippet.new
    paramArray.split(/\n/).each { |row| 
      col = row.split(/\t/)
      name = col[0]
      calc = col[1]
      rep = col[2]
      rep ||= 1
      doc.stepSetVariable(name,rep,calc)
    }
    doc.to_xml
  rescue => e
    return_error(e)
  end
end

desc "Uses tabular array to generate fmxmlsnippet of FileMaker Sort script steps"
doc %Q{
## Array to Sort Script Steps

### Description
Generates FileMaker snippet of Sort script steps.
Dialogs are suppressed by default.
Uses selected text or entire document.

### Compatibility
FileMaker 7 or newer

### Example Usage
Copy the lines below into a document and run the command again to see it work.

~~~~
Contacts::Company
Contacts\tTitle\tdescending
~~~~

### Parameters

#### Usage A

| Column  | Definition    | Default Value | Required? |
|:--------|:--------------|:--------------|:----------|
| 1 | table name  | | Yes |
| 2 | field name  | | Yes |
| 3 | sort direction {ascending|descending}  | ascending  | No |

#### Usage B

| Column  | Definition    | Default Value | Required? |
|:--------|:--------------|:--------------|:----------|
| 1 | table::field  | | Yes |
| 2 | sort direction {ascending|descending}  | ascending  | No |

### Tips
#{tips}
}
command :array_to_sort do |paramArray|
  suppressDialog = true
  doc = Snippet.new
  paramArray.split(/\n\n/).each { |chunk|
    arg = []
    chunk.split(/\n/).each { |row|
      col = row.split(/\t/)
      if not col[0].include?("::")
        col[0] = col[0] + '::' + col[1]
        col.slice!(1)
      end
      arg << {
        :field      => col[0],
        :direction  => col[1] || 'Ascending'
      }
    }
    doc.stepSort(arg)
  }
  doc.to_xml
end

desc "Uses tabular array to generate fmxmlsnippet of FileMaker Sort script steps wrapped in If/Else If tests"
doc %Q{
## Array to Sort Script Steps with Tests

### Description
Generates FileMaker snippet of Sort script steps.  
Each sort step is preceded by an Else If statement.  
Dialogs are suppressed by default.  
Uses selected text or entire document.

### Compatibility
FileMaker 7 or newer

### Example Usage
Copy the lines below into a document and run the command again to see it work.

#### Input

~~~~
$_field = "company"\tContacts::Company
$_field = GetFieldName ( Contacts::Title )\tContacts\tTitle\tDescending
~~~~

#### Output

~~~~
=> If [$_field = "company"]
=> 	Sort Records [Restore; No Dialog]
=> Else If [$_field = GetFieldName ( Contacts::Title )]
=> 	Sort Records [Restore; No Dialog]
=> End If
~~~~

### Parameters

#### Usage A

| Column  | Definition    | Default Value | Required? |
|:--------|:--------------|:--------------|:----------|
| 1 | calculation for If/Else If statement  | | Yes |
| 2 | table name  | | Yes |
| 3 | field name  | | Yes |
| 4 | sort direction {ascending|descending} | ascending | No |

#### Usage B

| Column  | Definition    | Default Value | Required? |
|:--------|:--------------|:--------------|:----------|
| 1 | calculation for If/Else If statement  | | Yes |
| 2 | table::field  | | Yes |
| 3 | sort direction {ascending|descending} | ascending | No |

### Tips
#{tips}
}
command :array_to_sort_with_tests do |paramArray|
  begin
    doc = Snippet.new
    rep = 0
    paramArray.split(/\n/).each { |row|
      col = row.split(/\t/)
      calc = col[0]
      rep += 1
      rep == 1 ? doc.stepIf(calc) : doc.stepElseIf(calc)
      if not col[1].include?("::")
        col[1] = col[1] + '::' + col[2]
        col.slice!(2)
      end
      arg = [{
        :field			=> col[1],
        :direction		=> col[2]
      }]
      doc.stepSort(arg)
    }
    doc.stepEndIf
    doc.to_xml
  rescue => e
    return_error(e)
  end
end

desc "Uses tabular array to generate a fmxmlsnippet of FileMaker layout field objects in shape of a grid"
doc %Q{
## Array to Field Grid

### Description
Generates FileMaker snippet of Field layout objects.  
Creates grid of fields with specified dimensions and spacing.  
Each field is pasted with an optional Perform Script button action.  
Uses selected text or entire document.  

### Compatibility
FileMaker 12 or newer

### Example Usage
Copy the lines below into a document and run the command again to see it work.
Be sure to update the field name to a valid repeating field.

#### Input

~~~~
Contacts::Global\t4\t4\t1\t20\t40\t0\t0\t86\t"param"\t"\#{rep}"
~~~~

#### Output

Square grid of 16 fields.

### Parameters

| Column  | Definition    | Default Value | Required? | Comments  |
|:--------|:--------------|:--------------|:----------|:----------|
| 1 | fully qualified field name  | | Yes | |
| 2 | row count  | | Yes |  |
| 3 | column count  | | Yes | |
| 4 | rep start | 1 | No |  |
| 5 | fieldHeight | fontSize + 10pt or 22pt | No |  |
| 6 | fieldWidth  | 120 | No |  |
| 7 | marginTop | -1 | No | Use -1 to have borders overlap exactly |
| 8 | marginRight | -1 | No | Use -1 to have borders overlap exactly |
| 9 | script id | | No | Inspect fmxmlsnippet of the script itself. ID is in the "id" attribute of the "Script" element. |
| 10 | script parameter | | No | Supports Ruby-like expressions (see below) |
| 11 | tooltip  | | No | Supports Ruby-like expressions (see below) |
| 12 | objectName  | | No | Supports Ruby-like expressions (see below) |
| 13 | fieldPadding | | No | |

#### Ruby-style expressions

* Wrap strings in double quotes
* rep variable contains current repetition number
* Interpolate variables into strings like this:

~~~~
  "I am repetition \#{rep} of " & \$_count + \#{rep}
~~~~

See [Ruby wikibook](http://en.wikibooks.org/wiki/Ruby_Programming/Syntax/Literals) for more info.

### Tips
* You may get an error if the grid is too big. In that case, generate parts of the grid separately.
#{tips}
}
command :array_to_layout_field_grid do |paramArray|
  begin
    doc = Snippet.new
    paramArray.split(/\n/).each do |row|
      col = row.split(/\t/)
      fontSize = col[3].to_i
      fieldHeight = fontSize ? fontSize + 10 : 22
      options = {
        :fieldQualified   => col[0],
        :rowCount         => col[1],
        :colCount         => col[2],
        :repStart         => col[3] || 1,
        :fieldHeight      => col[4] || fieldHeight,
        :fieldWidth       => col[5] || 120,
        :marginTop        => col[6],
        :marginLeft       => col[7],
        :scriptID         => col[8],
        :scriptParam      => col[9],
        :tooltip          => col[10],
        :objectName       => col[11],
        :fieldPadding     => col[12],
      }
      doc.layoutFieldGrid(options)
    end
    doc.to_xml
  rescue => e
    return_error(e)
  end
end