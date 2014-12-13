#!/usr/bin/ruby -KU
# encoding: UTF-8
#
# command_docs.rb - Stores documenation for bundle commands
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

base_path = File.dirname(__FILE__)
require base_path + '/commands.rb'

class Commands


  desc "Loads function to clipboard as snippet"
  command :load_function do |text,prefixToPrototype|
    begin
      doc = FileMaker::Snippet.new(text)
      calc = doc.parse_function(text,prefixToPrototype)
      doc.append(calc)
      result = FileMaker::Clipboard.set(doc)
      puts "Function ready to paste into FileMaker"
    rescue Exception => e
    	puts "Unrecognized function format.\nRun this command on an empty document for instructions."
    	puts e.message
    end
  end

end
