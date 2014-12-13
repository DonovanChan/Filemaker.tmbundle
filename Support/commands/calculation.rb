#!/usr/bin/ruby -KU
# encoding: UTF-8
#
# calculation.rb - Manipulates FileMaker calculations
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

tips = %Q{}

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

desc "Builds Case statement from tab-delimited array"
doc %Q{
## Array to Case Statement

### Description
Builds Case statement from tab-delimited array.


### Example Usage
Copy the lines below into a document and run the command again to see it work.

#### Input:
~~~~
$_city = "Oakland"\t"Sunny"
$_city = "Portland"\t"Caffeinated"\tGo Timbers
~~~~

#### Output:
When text is selected:

~~~~
$_city = "Oakland"	; "Sunny" ;
$_city = "Portland"	; "Caffeinated"	// Go Timbers
~~~~

When document used as input:

~~~~
Case (
  $_city = "Oakland"	; "Sunny" ;
  $_city = "Portland"	; "Caffeinated"	// Go Timbers
)
~~~~

### Parameters

| Column  | Definition    | Default Value | Required? |
|:--------|:--------------|:--------------|:----------|
| 1 | test  | | Yes |
| 2 | result | | Yes |
| 3 | comment | | No |

### Tips
* Use the Prepend to Column command on your array to add repetitive values like `$_city = `
}
command :array_to_case do |paramArray|
  paramArray.gsub!('$','\$')
  res = []
  begin
    paramArray.split(/\n/).each do |row|
    	col = row.split(/\t/)
    	res << "#{col[0].to_s}\t; #{col[1].to_s}" + (col[2] ? "\t// #{col[2].to_s}" : '' )
    end
    if ENV['TM_SELECTED_TEXT'].nil?
      "Case (\n\t" + res.join(" ;\n\t") + "\n)"
    else
      res.join(" ;\n")
    end
  rescue => e
    return_error(e)
  end
end

desc "Builds Substitute statement from tab-delimited array"
doc %Q{
## Array to Substitute Statement

### Description
Builds Substitute statement from tab-delimited array.


### Example Usage
Copy the lines below into a document and run the command again to see it work.

#### Input:
~~~~
"first_name"\t"First Name"
"title"\tProper ( "title" )\tCalculations work too
~~~~

#### Output:
When text is selected:

~~~~
[ "first_name"	; "First Name" ] ;
[ "title"	; Proper ( "title" ) ]	//Calculations work too
~~~~

When document used as input:

~~~~
Substitute (
	[ "first_name"	; "First Name" ] ;
	[ "title"	; Proper ( "title" ) ]	//Calculations work too
)
~~~~

### Parameters

| Column  | Definition    | Default Value | Required? |
|:--------|:--------------|:--------------|:----------|
| 1 | searchString  | | Yes |
| 2 | replaceString | | Yes |
| 3 | comment | | No |
}
command :array_to_substitute do |paramArray|
  res = []
  begin
    paramArray.split(/\n/).each do |row|
    	col = row.split(/\t/)
    	res << "[ #{col[0].to_s}\t; #{col[1].to_s} ]" + (col[2] ? "\t// #{col[2].to_s}" : '' )
    end
    if ENV['TM_SELECTED_TEXT'].nil?
      "Substitute (\n\t" + res.join(" ;\n\t") + "\n)"
    else
      res.join(" ;\n")
    end
  rescue => e
    return_error(e)
  end
end

desc "Convert & to List"
doc %Q{
## Convert & to List

### Description
Breaks &-concatenated list into List( ) statement.

### Example Usage
Copy the lines below into a document and run the command again to see it work.

#### Input:

~~~~
$_street &
$_city & " " & $_state
~~~~

#### Output:
When text is selected:

~~~~
$_street ;
$_city & " " & $_state
~~~~

When document used as input:

~~~~
List (
  $_street ;
  $_city & " " & $_state
)
~~~~
}
command :ampersand_to_list do |text|
  res = text.split(/\s*&\s*\n/)
  begin
    if ENV['TM_SELECTED_TEXT'].nil?
      "List (\n\t" + res.join(" ;\n\t") + "\n)"
    else
      res.join(" ;\n")
    end
  rescue => e
    return_error(e)
  end
end

desc "Converts literal text into List( ) statement, ensuring blank lines are preserved exactly."
doc %Q{
## Quote Lines in List( )

### Description
Converts literal text into List( ) statement, ensuring blank lines are preserved exactly.

### Example Usage
Copy the lines below into a document and run the command again to see it work.

#### Input:

~~~~
Oakland¶SF

Portland
~~~~

#### Output:

~~~~
List (
  "Oakland\¶SF" & ¶ ;
  "Portland"
)
~~~~

}
command :quote_lines_in_list do |text|
  begin
    FileMaker::Calc.string_to_list(text)
  rescue => e
    return_error(e)
  end
end

desc "Converts literal text into List( ) statement, adding space to blank lines so that List( ) function reads cleanly."
doc %Q{
## Quote Lines in List( ) Readable

### Description
Converts literal text into List( ) statement. Adds space to blank lines so that List( ) function reads cleanly."

### Example Usage
Copy the lines below into a document and run the command again to see it work.

#### Input:

~~~~
Oakland¶SF

Portland
~~~~

#### Output:

~~~~
List (
  "Oakland\¶SF" ;
  " " ;
  "Portland"
)
~~~~

}
command :quote_lines_in_list_readable do |text|
  begin
    FileMaker::Calc.string_to_list_readable(text)
  rescue => e
    return_error(e)
  end
end

desc "Moves delimiters to beginning of lines"
doc %Q{
## Move Delimiters to Beginning of Lines

### Description
Moves delimiters to beginning of lines

### Example Usage
Copy the lines below into a document and run the command again to see it work.

#### Input:

~~~~
Let ( [
  city = "Oakland" ;
  state = "CA" ;
  population =
    390724 +
    1
  ] ;
  If (
    city = "SF" or
    city = "Oakland" ;
      state &
      city
  )
)
~~~~

#### Output:

~~~~
Let ( [
  city = "Oakland"
  ; state = "CA"
  ; population =
    390724
    + 1
  ] ;
  If (
    city = "SF"
    or city = "Oakland"
      ; state
      & city
  )
)
~~~~

}
command :move_delimiters_to_beginning do |text|
  begin
    FileMaker::Calc.prepend_delims(text)
  rescue => e
    return_error(e)
  end
end

desc "Moves delimiters to beginning of lines"
doc %Q{
## Move Delimiters to Beginning of Lines

### Description
Moves delimiters to beginning of lines

### Example Usage
Copy the lines below into a document and run the command again to see it work.

#### Input:

~~~~
Let ( [
  city = "Oakland"
  ; state = "CA"
  ; population =
    390724
    + 1
  ] ;
  If (
    city = "SF"
    or city = "Oakland"
      ; state
      & city
  )
)
~~~~

#### Output:

~~~~
Let ( [
  city = "Oakland" ;
  state = "CA" ;
  population =
    390724 +
    1
  ] ;
  If (
    city = "SF" or
    city = "Oakland" ;
      state &
      city
  )
)
~~~~

}
command :move_delimiters_to_end do |text|
  begin
    FileMaker::Calc.append_delims(text)
  rescue => e
    return_error(e)
  end
end