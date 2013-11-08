#!/System/Library/Frameworks/Ruby.framework/Versions/1.8/usr/bin/ruby -KU
# encoding: UTF-8
#
# filemaker.rb - Parent for all FileMaker-related classes
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

class Hash

  # Removes pairs in hash with empty values
  def delete_blank
    delete_if{|k, v| v.to_s.empty? or v.instance_of?(Hash) && v.delete_blank.empty?}
  end

end

def Boolean(text)
  return true if text == true || text =~ (/^(true|t|yes|y|1)$/i)
  return false if text == false || text.nil? || text =~ (/^(false|f|no|n|0)$/i)
  raise ArgumentError.new(%q{invalid value for Boolean: "#{text}"})
end

module FileMaker

  PATH_BASE = File.dirname(__FILE__)
  PATH_PASTE = "#{PATH_BASE}/PasteSnippet.applescript"
  PATH_CUSTOM = "#{PATH_BASE}/filemaker/custom"

  # Change to 'true' to see backtrace with error messages
  DEBUG_ON = Boolean(ENV['TM_DEBUG_ON']) || false

  require "#{PATH_BASE}/filemaker/calc.rb"
  require "#{PATH_BASE}/filemaker/fmsnippet.rb"

  # Customizations
  require "#{PATH_BASE}/filemaker/custom/custom_function.rb"
  require "#{PATH_BASE}/filemaker/custom/custom_script.rb"

  # Clipboard interaction
  require "#{PATH_BASE}/filemaker/clipboard.rb"

  # Help
  require "#{PATH_BASE}/filemaker/help.rb"

end