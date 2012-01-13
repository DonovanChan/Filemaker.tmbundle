#!/usr/bin/env ruby
#
# clipboard.rb - helps get and put FileMaker objects on the clipboard
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

module FileMaker
  
  PATH_BASE = File.dirname(__FILE__)
  PATH_PASTE = "#{PATH_BASE}/PasteSnippet.applescript"
  PATH_ENCODE = "#{PATH_BASE}/encoding.sh"

  # Encodes text for submission to AppleScript that loads fmxmlsnippet to the clipboard
  # @note Uses hard-coded placeholders for high-ascii characters. See PATH_ENCODE for logic.
  # @param [String] text 
  # @return [String] Text with extended ascii characters escaped with placeholders
  # @example
  #   "en-dash: –".encoded_text #=> "en-dash: #:8211:#"
  def self.encode_text(text)
    `"#{PATH_ENCODE}" "#{text}"`
  end
  
  # @see #self.encode_text
  def encode_text(text)
    self.encode_text(text)
  end

  # Loads fmxmlsnippet to the clipboard
  # @param [Types] Name Description
  def set_clipboard(text)
    shellScript = %Q[osascript "#{PATH_PASTE}" "#{encode_text(text)}"]
    system shellScript
  end
  
end