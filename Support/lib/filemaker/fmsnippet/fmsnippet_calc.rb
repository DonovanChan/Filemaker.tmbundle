#!/System/Library/Frameworks/Ruby.framework/Versions/1.8/usr/bin/ruby -KU
# encoding: UTF-8
#
# fmsnippet_calc.rb - helps manipulate and construct fmxmlsnippets for custom functions
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

require 'erb'

class FileMaker::Snippet

  here = File.dirname(__FILE__)

  require 'rexml/document'

  # Returns array of calculations in fmxmlsnippet
  def extract_calcs
    doc = REXML::Document.new(self.to_s)
    doc.elements.to_a("//Calculation").reduce([]){|memo,e| memo.concat(e.cdatas)}
  end

  # Given custom function definitions, returns array of names and parameters of each
  def extract_functions
    doc = REXML::Document.new(self.to_s)
    doc.elements.to_a("//CustomFunction").reduce([]) do |memo,fn|
      name = fn.attributes['name']
      params = fn.attributes['parameters']
      memo << name + ' ( ' + params.gsub(';',' ; ') + ' )'
    end
  end

  # Constructs custom function element and appends to @text
  # @param [String] name name of custom function
  # @param [String] params function parameters
  # @param [String] calculation function calculation
  # @example
  #   Snippet.new.customFunction('TabDelimit','text;currentDelimiter','Substitute ( text ; currentDelimiter ; " " )' )
  def customFunction(name,params,calculation)
    template = %q{
	<CustomFunction id="" functionArity="1" visible="True" parameters="<%= params %>" name="<%= name %>">
		<Calculation><![CDATA[<%= calculation %>]]></Calculation>
	</CustomFunction>}.gsub(/^\s*%/, '%')
    tpl = ERB.new(template, 0, '%<>')
    @text << tpl.result(binding)
  end

  def self.customFunction?(text)
    text =~ /<CustomFunction\b/ ? true : false
  end

end