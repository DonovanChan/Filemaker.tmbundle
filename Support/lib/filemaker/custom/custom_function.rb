#!/System/Library/Frameworks/Ruby.framework/Versions/1.8/usr/bin/ruby -KU
# encoding: UTF-8
#
# custom_function.rb - custom logic for manipulating FileMaker custom functions
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

# Handles actions specific to custom functions. Switch out this module to suite your own conventions.
module FileMaker::FunctionCustom

  # here = File.dirname(__FILE__)
  # require "#{here}/comments.rb"
  # include Comments

  # Parses custom function calculation to generate custom function snippet. Uses predetermined comment format to determine function name and parameters.
  # @param [String] calc Custom Function calculation (including comments documenting name and parameters)
  # @param [String] prefixToPrototype String that precedes example of custom function's syntax
  # @example
  #   parse_function(%Q{Substitute ( text ; currentDelimiter ; " " )\n//Name: TabDelimit ( text ; currentDelimiter )},"Name:")
  # @return [String,nil] XML element generated for custom function. Nil if syntax is unrecognized.
  def parse_function(calc,prefixToPrototype)
    begin
      string =
        calc.match(%r{(?:/\*|//).*?[\n\s]*#{prefixToPrototype}[\s\n]*(.+?)(?:\n|\*/)}m) ||
        calc.match(%r{//.*?\s*#{prefixToPrototype}\s*(.+?)$}m)
      nameFull = string[1]
      name = nameFull.match(/\s*(.+?)\(|\n/)[1].strip
      params = nameFull.match(/\((.*?)\)/)[1].gsub(/\s*/,'')
      self.customFunction(name,params,calc).to_s
    rescue
      raise ArgumentError, "Invalid function. Ensure there's a valid syntax example after '#{prefixToPrototype}'"
    end
  end

  # Returns calculation with operators and delimiters moved to end of each line
  # @param [String] calculation
  # @return [String] Calculation with operators and delimiters moved to end of each line
  # @example
  #   calc = "Let ( [\n\tanimal = \"dog\" //comment\n\t; habitat = \"house\"\n\t] ;\nanimal\n)"
  #   puts append_delims(calc) # => "Let ( [\n\tanimal = \"dog\" ; //comment\n\thabitat = \"house\"\n\t] ;\nanimal\n)"
  # @todo Remove quoted strings, cplus comments, and c comments before processing
  # @todo Fix bug whereby delim is inserted after comments
  def append_delims(calculation)
    # Preserve special delimiters like '];' with placeholders
    calculation.gsub!(/^(\s*)\](\s*);(\s*)$/,"\\1::93::\\2::59::\\3")
    regex = /^(\s*(?:\/\*.*?\/\*)*)           (?# Leading whitespace and comments)
            ([;&+\-<>≤≥≠^]
            |(?:and|or|not|xor))\s*
            /x

    delim = nil
    array = calculation.split("\n").reverse.map do |line|

      # Skip comments
      if line =~ %r{^(\s*|\s*//)$}
        line
      else
        # Append delim from previous line
        # line = delim ? line.gsub(/(?:\s*|(\s*\/\/.*?))$/,"#{delim}\\1") : line
        # puts line.match(/(?:\s*|(\s*\/\/.*?))$/).inspect
        line = delim ? line.gsub(/(?:\s*|(\s*\/\/.*?))$/," #{delim}\\1") : line

        # Store delim to carry to next line
        match = line.match(regex)
        delim = match ? match[2] : nil

        # Strip delim from current line
        line.gsub!(regex,"\\1")
        line
      end
    end
    calculation = array.reverse.join("\n")
    calculation.gsub('::93::',']').gsub('::59::',';')
  end

  # Returns calculation with operators and delimiters moved to begining of each line
  # @param [String] calculation
  # @return [String] Calculation with operators and delimiters moved to begining of each line
  # @example
  #   calc = "Let ( [\n\tanimal = \"dog\" ; //comment\n\thabitat = \"house\"\n\t] ;\nanimal\n)"
  #   puts prepend_delims(calc) # => "Let ( [\n\tanimal = \"dog\" //comment\n\t; habitat = \"house\"\n\t] ;\nanimal\n)"
  # @todo Remove quoted strings, cplus comments, and c comments before processing
  def prepend_delims(calculation)
    # Preserve special delimiters like '];' with placeholders
    calculation.gsub!(/^(\s*)\](\s*);(\s*)$/,"\\1::93::\\2::59::\\3")

    regex = /\s*
            ([;&+\-<>≤≥≠^]
            |(?:and|or|not|xor))
            (?:\s*|(\s*\/\/.*?))?$          (?# Preserve end-of-line comments)
            /x

    delim = nil
    array = calculation.split("\n").map do |line|

      # Skip comments
      if line =~ %r{^\s*//}
        line
      else
        # Prepend delim from previous line
        line = delim ? line.gsub(/^(\s*)/,"\\1#{delim} ") : line

        # Store delim to carry forward
        match = line.match(regex)
        delim = match ? match[1] : nil

        # Strip delim from current line
        line.gsub!(regex,"\\2")
        line
      end
    end
    calculation = array.join("\n")
    calculation.gsub('::93::',']').gsub('::59::',';')
  end

  # Returns list of appended lines as List( ) calculation
  # @param [String] calculation Calculation to be converted
  # @return [String] Calculation wrapped in List( ) function with any trailing ampersand (&) on a line replaced with a semi-colon (;)
  # @example
  #   puts to_list("$_dog &\n$_cat &\n$_mouse") # => "List (\n$_dog ;\n$_cat ;\n$_mouse\n)"
  def to_list(calculation)
    return '' unless calculation
    calculation.gsub!(/&\s*$/,";")
    "List (\n  #{calculation}\n)"
  end

  # Stub currently just used for testing and documentation
  def function_example
    %Q{
number ^ 2

/* ---------------------------------- //
NAME:
\tsquared ( number )

NOTES:
\tThe important part is to prepend your syntax example with "NAME:"

*/}
  end

end

module FileMaker
  include FileMaker::FunctionCustom
end