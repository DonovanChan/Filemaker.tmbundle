#!/usr/bin/ruby -KU
# encoding: UTF-8
#
# commands.rb - Allows for easy mapping of metadata to methods
#
# Author::      Donovan Chandler using code by Alex Gibbons (mailto:donovan_c@beezwax.net)
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

base_path = File.dirname(__FILE__)
gem_path = File.dirname(base_path) + '/resources'
$LOAD_PATH.unshift(gem_path + '/kramdown/lib')
require 'kramdown.rb'

module Commands

  attr_reader :commands

  def self.desc(description)
    @next_desc = description
  end

  def self.doc(documentation)
    @next_doc = process_doc(documentation)
  end

  def self.command(name, &blk)
    @commands ||= {}
    @commands[name] = {
      :block => blk,
      :description => Kramdown::Document.new(@next_desc),
      :documentation => Kramdown::Document.new(@next_doc, :coderay_tab_width => 4)
    }
  end

  def self.call(name,*args)
    @commands[name][:block].call(*args)
  end

  def self.description(name)
    @commands[name][:description]
  end

  def self.documentation(name)
    @commands[name][:documentation]
  end

  def self.process_doc(documentation)
    return '' unless documentation
    convert_tabs(documentation,2)
  end

  private

  def self.convert_tabs(text,tab_width)
    # text.gsub(/^( {2})+/) { |spaces| "\t" * (spaces.length / tab_width) }
    text.gsub(/(?:^|\G) {#{tab_width}}/m,"\t")
  end

end


module Delegator
  def self.delegate(*methods)
    methods.each do |method_name|
      define_method(method_name) do |*args, &block|
        return super(*args, &block) if respond_to? method_name
        Delegator.target.send(method_name, *args, &block)
      end
      private method_name
    end
  end

  delegate :desc, :doc, :command, :call, :documentation

  class << self
    attr_accessor :target
  end

  self.target = Commands
end

include Delegator
