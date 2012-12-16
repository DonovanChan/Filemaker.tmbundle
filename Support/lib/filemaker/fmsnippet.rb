#!/usr/bin/env ruby -KU
# encoding: UTF-8
#
# fmsnippet.rb - helps manipulate and construct FileMaker clipboard XML (snippets)
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

# Handles generation and parsing of fmxmlsnippets,
# which is the XML syntax used by FileMaker to describe objects
# on the clipboard.
class FileMaker::Snippet

  PATH_BASE = File.dirname(__FILE__)
  ROOT = 'fmxmlsnippet'
  
  require 'erb'
  require 'rexml/document'
  path_children = "#{PATH_BASE}/fmsnippet"
  require "#{path_children}/fmsnippet_calc.rb"
  require "#{path_children}/fmsnippet_layout.rb"
  require "#{path_children}/fmsnippet_schema.rb"
  require "#{path_children}/fmsnippet_script.rb"
  require "#{path_children}/fmsnippet_pre12.rb"

  attr_accessor :type, :text

  # Creates Snippet object
  # @param [optional, String] XML text to be added to Snippet @text as fmxmlsnippet
  def initialize(xmlText='')
    @text = xmlText
    @isPartial = true unless xmlText =~ /\<#{ROOT}[\s\>]/u
  end

  # Sets @type of Snippet object. Determines type by inspecting Snippet @text elements.
  # @param [optional, String] Used to override default determination. Valid values: LayoutObjectList.
  # @return [true] Currently performs no error handling
  def set_type(type='')
    case @text
    when /\<Layout enclosing/, /\<ObjectStyle\b/, /\<LocalCSS\b/, type == 'LayoutObjectList'
      @type = 'LayoutObjectList'
      @boundTop = 0
    when /\<Step\b/
      @type = 'FMObjectList'
    else
      @type = 'FMObjectList'
    end
    true
  end
    
  # Ensures snippet objects are wrapped in root XML elements
  def enclose
    self.set_type
    header = %Q{<?xml version="1.0" encoding="UTF-8"?>\n<#{ROOT} type="#{@type}">}
    footer = "\n</#{ROOT}>"
    if @type == 'LayoutObjectList' && !@text.match(/<Layout/i)
      @text = @text.insert(0,"\n\t<Layout>")
    end
    @text = @text.insert(0,header) unless @text.to_s.include?("<#{ROOT}")
    if @type == 'LayoutObjectList' && !@text.match(/<\/Layout>/i)
      @text = @text.concat("\n\t</Layout>")
    end
    @text = @text.concat(footer) unless @text.include?("</#{ROOT}>")
  end

  # Prints @text (fmxmlsnippet text) as readable string
  def to_s
    self.enclose
    @text.lstrip!
    @text
  end
  
  # Prints snippet as text as would use in clipboard
  def to_xml
    self.enclose
    @text.lstrip!
    @text
  end
  
  # Appends text to @text
  # @param [String] text XML text (presumably in fmxmlsnippet format)
  # @return [String] New values of @text
  def append(text)
    @text << text
  end
    
end