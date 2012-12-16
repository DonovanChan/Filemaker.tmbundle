#!/usr/bin/env ruby -KU
# encoding: UTF-8
#
# fmcalc.rb - manipulates FileMaker calculations
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

# Manipulates FileMaker calculations
module FileMaker::Calc
  
  # here = File.dirname(__FILE__)
  # require "#{here}/comments.rb"
  # include Comments

  # Coerces string into boolean.
  # @param [String] string String to coerce into boolean
  # @return [true, false] Defaults to true unless string = (false|f|no|0)
  def self.Boolean(string)
    string = string.to_s
    case string
      when /^(false|f|no|0)$/i
        false
      else
        string.class == String
    end
  end
  
  # Extracts names of functions used in text
  # @param [String] text Calculation containing function names to extract
  # @return [Array] Names of functions in text
  def self.extract_functions(text)
    text.to_s.scan(/[#a-zA-Z\._-]+?(?=\s*\()/)
  end

  # Parses fully qualified field name to return table occurrence
  # @param [String] fieldName Fully qualified field name
  # @return [String] Name of table occurrence
  # @example
  #   puts field_table('CONTACT_PARENT::NAME') # =>  'CONTACT_PARENT'
  def self.field_table(fieldName)
    fieldName = fieldName.to_s
    if fieldName.include?("::")
      fieldName.split(/::/)[0]
    end
  end

  # Parses fully qualified field name to return name of field
  # @param [String] fieldName Fully qualified field name
  # @return [String] Name of field
  # @example
  #   puts field_name('CONTACT::NAME') # => 'NAME'
  def self.field_name(fieldName)
    fieldName = fieldName.to_s
    if fieldName.include?("::")
      fieldName.split(/::/)[1]
    else
      fieldName
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
  # @todo Figure out how to encode not-equals and exponent signs properly
  def append_delims(calculation)
    # Preserve special delimiters like '];' with placeholders
    calculation.gsub!(/^(\s*)\](\s*);(\s*)$/,"\\1::93::\\2::59::\\3")

    regex = /^(\s*(?:\/\*.*?\/\*)*)           (?# Leading whitespace and comments)
            ([;&+\-<>≤≥#{94.chr}]
            |(?:and|or|not|xor))\s*
            /xu

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
    return "List (\n  #{calculation}\n)"
  end
  
  # Escapes and quotes text for use as literal string in FileMaker
  def self.quote(text)
    text.gsub!(/"/,'\\"')
    text.gsub!(/\\/,'\\')
    text.gsub!(/¶/,'\\¶')
    '"' + text + '"'
  end
  
  # Converts literal text into List( ) statement. Ensures blank lines are preserved exactly.
  # @example
  #   string_to_list("Oakland\n\nPortland") # => "List (\n\t\"Oakland\" & ¶ ;\n\t\"Portland\"\n)"
  def self.string_to_list(text)
    lines = []
    text.split(/\n/).each_with_index do |line,index|
      if line.empty?
        lines[index-1] += ' & ¶'
      else
        lines << quote(line)
      end
    end
    %Q!List (\n\t#{lines.join(" ;\n\t")}\n)!
  end
  
  # Converts literal text into List( ) statement. Adds space to blank lines so that List( ) function reads cleanly.
  # @example
  #   string_to_list_readable("Oakland\n\nPortland") # => "List (\n\t\"Oakland\" ;\n\t" " ;\n\t"Portland\"\n)"
  def self.string_to_list_readable(text)
    lines = []
    text.split(/\n/).each_with_index do |line,index|
      line = ' ' if line.empty?
      lines << quote(line)
    end
    %Q!List (\n\t#{lines.join(" ;\n\t")}\n)!
  end
  
  
end