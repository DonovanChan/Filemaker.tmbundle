#!/usr/bin/ruby -KU
# encoding: UTF-8
#
# fmsnippet_layout.rb - helps manipulate and construct fmxmlsnippets for layouts
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
require 'rexml/document'

class FileMaker::Snippet

  # Returns array of object names from fmxmlsnippet of layout objects
  def extract_object_names
    doc = REXML::Document.new(self.to_s)
    doc.elements.to_a("//Object").reduce([]){|memo,e| memo << e.attributes['name'] }
  end

  def extract_object_css
    doc = REXML::Document.new(self.to_s)
    doc.elements.to_a("//LocalCSS").reduce([]){|memo,e| memo << e.text.lstrip }
  end

  # Constructs layout field object and appends to @text
  # @param [Hash] options Hash containing field object attributes
  # @option options [String] :field Name of field
  # @option options [String] :table Name of table
  # @option options [String] :fieldQualified Fully qualified field name (e.g., CONTACT::NAME). Can be used in lieu of field and table options
  # @option options [String] :tooltip
  # @option options [String] :font
  # @option options [Integer] :fontSize
  # @option options [String] :objectName
  # @option options [Integer] :fieldHeight
  # @option options [Integer] :fieldWidth
  # @option options [Integer] :fieldTop If left empty, will increment on its own. Provide value of 0 when field will be contained in parent object.
  # @option options [Integer] :fieldLeft
  # @option options [Integer] :marginTop Space between bottom of previous field to top of current field being generated.
  # @option options [String] :script
  # @option options [String] :scriptParameter
  # @option options [String] :padding E.g. "0em"
  # @return [String] XML element generated for object. Also updates @boundTop and @boundBottom, which store absolute position value of most recently generated field.
  def layoutField(options={})
    self.set_type('LayoutObjectList')
    fieldQualified = options[:fieldQualified]
    if fieldQualified
      table = FileMaker::Calc.field_table(fieldQualified)
      field = FileMaker::Calc.field_name(fieldQualified)
    else
      table = options[:table]
      field = options[:field]
      fieldQualified = table + "::" + field
    end
    options = {
      :font         => "Verdana",
      :fontSize     => 12,
      :fieldWidth   => 120,
      :fieldLeft    => 0
    }.merge(options.delete_blank)
    options[:fieldHeight] ||= options[:fontSize].to_i + 10
    options[:marginTop] ||= 2

    # Absolute measurements
    @boundTop = @boundBottom.nil? ? 0 : @boundBottom.to_i + options[:marginTop].to_i
    @boundBottom = @boundTop + options[:fieldHeight].to_i
    @boundLeft = options[:fieldLeft]

    # Relative measurements (used when contained by parent object)
    if options[:fieldTop].nil?
      options[:fieldTop] = @boundTop
      fieldBottom = @boundBottom
    else
      fieldBottom = options[:fieldTop].to_i + options[:fieldHeight].to_i
    end
    template = %q{
		<Object type="Field" key="" LabelKey="" name="<%= options[:objectName] %>" flags="" rotation="0">
			<Bounds top="<%= options[:fieldTop] %>" left="<%= options[:fieldLeft] %>" bottom="<%= fieldBottom %>" right="<%= options[:fieldLeft].to_i + options[:fieldWidth].to_i %>"/>
			<% if options[:tooltip] %><ToolTip>
				<Calculation><![CDATA[<%= options[:tooltip] %>]]></Calculation>
			</ToolTip><% end %>
			<FieldObj numOfReps="1" flags="" inputMode="0" displayType="0" quickFind="1" pictFormat="5">
				<Name><%= fieldQualified %></Name>
				<Styles>
					<LocalCSS>
						self {
							font-family: -fm-font-family(<%= options[:font] %>);
							font-size: <%= options[:fontSize] %>;
						}<% if options[:fieldPadding] %>
						self .inner_border { padding: <%= options[:fieldPadding] %>; }
					<% end %></LocalCSS>
				</Styles>
			</FieldObj>
		</Object>}.gsub(/^\s*%/, '%')
    tpl = ERB.new(template, 0, '%<>')
    xml = tpl.result(binding)
    @text << xml
    xml
  end

  # Constructs layout field object with label and appends to @text
  def layoutFieldWithLabel(fieldOptions,labelText,labelOptions={},labelMarginRight = 11)
    field = self.layoutField(fieldOptions)
    labelOptions[:width] ||= 100
    labelOptions = {
      :top    => @boundTop,
      :left   => @boundLeft.to_i - labelOptions[:width].to_i - labelMarginRight.to_i
    }.merge(labelOptions.delete_blank)
    self.layoutText(labelText,labelOptions)
  end

  # Constructs layout text object and appends to @text
  # @param [String] text String to display
  # @param [Hash] options Hash containing text object attributes
  # @option options [String] :font
  # @option options [Integer] :fontSize
  # @option options [Integer] :height
  # @option options [String] :justification Alignment of text. 1 for left, 2 for center, 3 for right.
  # @option options [Integer] :leftMargin Padding of text inside of object
  # @option options [Integer] :rightMargin Padding of text inside of object
  # @option options [String] :textColor Hex value of text color
  # @option options [Integer] :width
  # @return [String] XML element generated for object.
  def layoutText(text,options={})
    self.set_type('LayoutObjectList')
    return nil unless text
    options = {
      :font           => "Verdana",
      :fontSize       => 12,
      :justification  => 3,
      :textColor      => '#000000',
      :width          => 120
    }.merge(options.delete_blank)
    options[:height] ||= options[:fontSize].to_i + 10
    template = %q{
		<Object type="Text" key="" LabelKey="0" name="" flags="0" rotation="0">
			<Bounds top="<%= options[:top].to_i %>" left="<%= options[:left].to_i %>" bottom="<%= options[:top].to_i + options[:height].to_i %>" right="<%= options[:left].to_i + options[:width].to_i %>"/>
			<TextObj flags="0">
				<Styles>
					<LocalCSS>
					self {
						font-size: <%= options[:fontSize] %>;
						text-align: <%= options[:justification] %>;
						<%= "-fm-paragraph-margin-left: #{options[:leftMargin].to_i};" if options[:leftMargin] %>
						<%= "-fm-paragraph-margin-right: #{options[:RightMargin].to_i};" if options[:RightMargin] %>
					}
					</LocalCSS>
				</Styles>
				<CharacterStyleVector>
					<Style>
						<Data><%= text %></Data>
						<CharacterStyle mask="32695">
							<Font-family codeSet="" fontId=""><%= options[:font] %></Font-family>
							<Font-size><%= options[:fontSize] %></Font-size>
							<Face>0</Face>
							<Color><%= options[:textColor] %></Color>
						</CharacterStyle>
					</Style>
				</CharacterStyleVector>
			</TextObj>
		</Object>}.gsub(/^\s*%/, '%')
    tpl = ERB.new(template, 0, '%<>')
    xml = tpl.result(binding)
    @text << xml
    xml
  end

  # Constructs layout field object with label and assigns script to field. Appends resulting XML to @text.
  # @option (see #layoutField)
  # @option options [String] :scriptID FileMaker's internal ID for script. You'll need to get this off of the clipboard.
  # @option options [String] :scriptParam FileMaker calculation
  # @return [String] XML element generated for object.
  def layoutFieldButton(options={})
    self.set_type('LayoutObjectList')

    options[:fieldHeight] ||= options[:fontSize].to_i + 10
    options = {
      :fieldWidth   => 120,
      :fieldLeft    => 0,
      :marginTop    => -1
    }.merge(options.delete_blank)
    fieldOptions = options.merge({
      :fieldTop   => 0,
      :fieldLeft => 0,
      :objectname => nil
    })

    # Prevent field from getting added to @text (I know, this is ugly)
    textOrig = @text.dup
    field = self.layoutField(fieldOptions)
    @text = textOrig

    if options[:fieldTop].nil?
      fieldBottom = @boundBottom
    else
      fieldBottom = options[:fieldTop].to_i + options[:fieldHeight].to_i
    end

    template = %q{
		<Object type="GroupButton" key="" LabelKey="0" name="<%= options[:objectName] %>" flags="" rotation="0">
			<Bounds top="<%= options[:fieldTop] || @boundTop %>" left="<%= options[:fieldLeft] %>" bottom="<%= fieldBottom %>" right="<%= options[:fieldLeft].to_i + options[:fieldWidth].to_i %>"/>
			<GroupButtonObj numOfObjs="1">
				<Step enable="True" id="" name="Perform Script">
					<CurrentScript value="Pause"/>
					<Calculation><![CDATA[<%= options[:scriptParam] %>]]></Calculation>
					<Script id="<%= options[:scriptID] %>" name="<%= options[:scriptName] %>"/>
				</Step><%= field.gsub(/^/,"\t"*2) %>
			</GroupButtonObj>
		</Object>}.gsub(/^\s*%/, '%')
    tpl = ERB.new(template, 0, '%<>')
    xml = tpl.result(binding)
    @text << xml
    xml
  end

  # Constructs layout field object with label and assigns script to field. Appends resulting XML to @text.
  # @option (see #layoutFieldButton)
  # @option options [Integer] :rowCount Number of rows to generate
  # @option options [Integer] :colCount Number of columns to generate
  # @option options [Integer] :marginTop Distance between top border of current field and bottom of field above it
  # @option options [Integer] :marginLeft Distance between left border of current field and right of adjacent field
  # @return [String] XML element generated for object.
  def layoutFieldGrid(options={})
    colWidth = options[:fieldWidth].to_i + options[:marginLeft].to_i
    rowHeight = options[:fieldHeight].to_i + options[:marginTop].to_i

    rep = options[:repStart].to_i || 1
    repMax = rep + options[:rowCount].to_i * options[:colCount].to_i - 1
    while rep <= repMax
      col = (rep.to_f / options[:rowCount].to_i).ceil
      row = rep % options[:rowCount].to_i
      row = rep/col if row == 0
      opt = options.dup.merge({
        :fieldQualified => options[:fieldQualified] + "[#{rep}]",
        :scriptParam    => eval(%Q[%Q[#{options[:scriptParam]}]]),
        :fieldLeft      => (col-1) * colWidth,
        :fieldTop       => (row-1) * rowHeight || 0,
        :tooltip        => eval(%Q[%Q[#{options[:tooltip]}]]),
        :objectName     => eval(%Q[[#{options[:objectName]}]])
      })
      options[:scriptID].empty? ? self.layoutField(opt) : self.layoutFieldButton(opt)
      rep += 1
    end
    self.to_xml
  end

end