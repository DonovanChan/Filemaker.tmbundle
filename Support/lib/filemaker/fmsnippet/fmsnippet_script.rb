#!/System/Library/Frameworks/Ruby.framework/Versions/1.8/usr/bin/ruby -KU
# encoding: UTF-8
#
# fmsnippet_script.rb - helps manipulate and construct fmxmlsnippets for scripts
#
# Author::      Donovan Chandler (mailto:donovan_c@beezwax.net)
# Copyright::   Copyright (c) 2010-2012 Donovan Chandler
# License::     Distributed under GNU General Public License <http://www.gnu.org/licenses/>
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of termshe GNU General Public License as published by
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

  # Constructs comment script step and appends to @text
  # @param [optional, String] text text for comment
  # @return [String] XML element generated for script step
  def stepComment(text=" ")
    template = %q{
	<Step enable="True" id="" name="Comment">
		<Text><%= text %></Text>
	</Step>
}.gsub(/^\s*%/, '%')
    tpl = ERB.new(template, 0, '%<>')
    @text << tpl.result(binding)
  end

  # Constructs script section header steps (comments) and appends to @text
  # @param [optional, String] text text for header
  # @return [String] XML element generated for script step
  def stepCommentHeader(text=" ")
    template = %q{
	<Step enable="True" id="" name="Comment"/>
	<Step enable="True" id="" name="Comment">
		<Text>__________________________________________________</Text>
	</Step>
	<Step enable="True" id="" name="Comment">
		<Text><%= text %></Text>
	</Step>
	<Step enable="True" id="" name="Comment"/>
}.gsub(/^\s*%/, '%')
    tpl = ERB.new(template, 0, '%<>')
    @text << tpl.result(binding)
  end

  # Constructs If script step and appends to @text
  # @param [optional, String] calculation FileMaker calculation for If condition
  # @return [String] XML element generated for script step
  def stepIf(calculation)
    template = %q{
	<Step enable="True" id="" name="If">
		<Calculation><![CDATA[<%= calculation %>]]></Calculation>
	</Step>}.gsub(/^\s*%/, '%')
    tpl = ERB.new(template, 0, '%<>')
    @text << tpl.result(binding)
  end

  # Constructions Else If script step and appends to @text
  # @param [optional, String] calculation FileMaker calculation for Else If condition
  # @return [String] XML element generated for script step
  def stepElseIf(calculation)
    template = %q{
	<Step enable="True" id="" name="Else If">
		<Calculation><![CDATA[<%= calculation %>]]></Calculation>
	</Step>}.gsub(/^\s*%/, '%')
    tpl = ERB.new(template, 0, '%<>')
    @text << tpl.result(binding)
  end

  # Constructs Else script step and appends to @text
  # @return [String] XML element generated for script step
  def stepElse
    template = %q{<Step enable="True" id="" name="Else"/>}.gsub(/^\s*%/, '%')
    tpl = ERB.new(template, 0, '%<>')
    @text << tpl.result(binding)
  end

  # Constructs End If script step and appends to @text
  # @return [String] XML element generated for script step
  def stepEndIf
    template = %q{<Step enable="True" id="" name="End If"/>}.gsub(/^\s*%/, '%')
    tpl = ERB.new(template, 0, '%<>')
    @text << tpl.result(binding)
  end

  # Constructs Exit Script script step and appends to @text
  # @param [String] calculation FileMaker calculation for exit condition
  # @return [String] XML element generated for script step
  def stepExitScript(calculation)
    template = %q{
	<Step enable="True" id="" name="Exit Script">
		<Calculation><![CDATA[<%= calculation %>]]></Calculation>
	</Step>}.gsub(/^\s*%/, '%')
    tpl = ERB.new(template, 0, '%<>')
    @text << tpl.result(binding)
  end

  # Constructs Exit Loop If script step and appends to @text
  # @param [String] calculation FileMaker calculation for exit condition
  # @return [String] XML element generated for script step
  def stepExitLoopIf(calculation)
    template = %q{
	<Step enable="True" id="" name="Exit Loop If">
		<Calculation><![CDATA[<%= calculation %>]]></Calculation>
	</Step>}.gsub(/^\s*%/, '%')
    tpl = ERB.new(template, 0, '%<>')
    @text << tpl.result(binding)
  end

  # Constructs Exit Script script step and appends to @text
  # @param [Hash] options Hash containing optional field attributes
  # @option options [String] :field Name of field
  # @option options [String] :table Name of table
  # @option options [String] :fieldQualified Fully qualified field name (e.g., CONTACT::NAME). Can be used in lieu of field and table options
  # @option options [Integer] :repetition
  # @option options [String] :calculation
  # @return [String] XML element generated for script step
  def stepSetField(options={})
    # options = { :repetition => 2 }.merge(options)
    fieldQualified = options[:fieldQualified]
    table = options[:table] ||= FileMaker::Calc.field_table(fieldQualified)
    field = options[:field] ||= FileMaker::Calc.field_name(fieldQualified)
    repetition = options[:repetition]

    # @todo Fix: Repetition element being created for number reps
    repCalc = repetition.class == Fixnum ? nil : repetition
    rep = repCalc ? 0 : repetition
    template = %q{
	<Step enable="True" id="" name="Set Field">
		<Calculation><![CDATA[<%= options[:calculation] %>]]></Calculation>
		<Field table="<%= table %>" id="" repetition="<%= rep %>" name="<%= field %>"></Field>
		% if repCalc
		<Repetition>
		 <Calculation><![CDATA[<%= repCalc %>]]></Calculation>
		</Repetition>
		% end
	</Step>}.gsub(/^\s*%/, '%')
    tpl = ERB.new(template, 0, '%<>')
    @text << tpl.result(binding)
  end

  # Constructs Set Variable script step and appends to @text
  # @param [String] name name of variable (including $ or $$)
  # @param [Integer] rep repetition number of variable being declared
  # @param [String] calc FileMaker calculation for exit condition
  # @return [String] XML element generated for script step
  def stepSetVariable(name,rep,calc)
    template = %q{
	<Step enable="True" id="" name="Set Variable">
		<Value>
			<Calculation><![CDATA[<%= calc %>]]></Calculation>
		</Value>
			% unless rep == 1 || nil
		<Repetition>
			<Calculation><![CDATA[<%= rep %>]]></Calculation>
		</Repetition>
			% end
		<Name><%= name %></Name>
	</Step>}.gsub(/^\s*%/, '%')
    tpl = ERB.new(template, 0, '%<>')
    @text << tpl.result(binding)
  end

  # fieldArray includes { field, direction }
  # Constructs Sort script step and appends to @text
  # @param [Array] fieldArray array containing fields
  # @param [Boolean] hideDialog True (default) displays sort dialog
  # @example
  #   fields = { :field => "CONTACT::NAME_FIRST", :direction => "Ascending" }
  #   fields << { :field => "CONTACT::NAME_LAST", :direction => "Descending" }
  #   Snippet.new.stepSort(fields,true)
  # @return [String] XML element generated for script step
  def stepSort(fieldArray,hideDialog=true)
    template = %q{
	<Step enable="True" id="" name="Sort Records">
		<NoInteract state="<%= Boolean(hideDialog).to_s.capitalize %>"/>
		<Restore state="True"/>
		<SortList value="True">
			% fieldArray.each do |field_cur|
				% direction = field_cur[:direction] || "Ascending"
				% fieldQualified = field_cur[:field]
				% table = FileMaker::Calc.field_table(fieldQualified)
				% name = FileMaker::Calc.field_name(fieldQualified)
				<Sort type="<%= direction.capitalize %>">
					<PrimaryField>
						<Field table="<%= table %>" id="" name="<%= name %>"/>
					</PrimaryField>
				</Sort>
			% end
		</SortList>
	</Step>}.gsub(/^\s*%/, '%')
    tpl = ERB.new(template, 0, '%<>')
    @text << tpl.result(binding)
  end

end