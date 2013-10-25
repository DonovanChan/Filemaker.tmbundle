#!/System/Library/Frameworks/Ruby.framework/Versions/1.8/usr/bin/ruby -KU
# encoding: UTF-8
#
# fmsnippet_schema.rb - helps manipulate and construct fmxmlsnippets for fields and tables
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

class FileMaker::Snippet

  here = File.dirname(__FILE__)
  require 'erb'
  require 'rexml/document'

  # Constructs Field and appends to @text
  # @param [String] name name of field (fully qualified)
  # @param [Hash] options Hash of field attributes
  # @option options [String] :type
  # @option options [String] :comment
  # @option options [true, false] :isGlobal
  # @option options [Integer] :repetitions
  # @option options [String] :calculation
  # @return [String] XML element generated for field
  def field(name,options={})
    name = FileMaker::Calc.field_name(name)
    options = {
      :type         => "Text",
      :isGlobal     => false,
      :repetitions  => 1
    }.merge(options.delete_blank)
    calc = options[:calculation]
    isGlobal = Boolean(options[:isGlobal]) ? "True" : "False"
    template = %q{
	<Field id="" dataType="<%= options[:type] %>" fieldType="<%= options[:calculation].nil? ? 'Normal' : 'Calculated' %>" name="<%= name %>">
		<Calculation table=""><![CDATA[<%= options[:calculation] %>]]></Calculation>
		<Comment><%= options[:comment] %></Comment>
		<Storage indexLanguage="English" global="<%= isGlobal %>" maxRepetition="<%= options[:repetitions] %>"/>
	</Field>}.gsub(/^\s*%/, '%')
    tpl = ERB.new(template, 0, '%<>')
    @text << tpl.result(binding)
  end

end