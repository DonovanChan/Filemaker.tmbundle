#!/usr/bin/env ruby
# encoding: UTF-8
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

module FileMaker::Clipboard

  require 'open3'

  # Defined in fmsnippet.rb
  PATH_BASE = File.dirname(__FILE__)
  PATH_COPY = "#{PATH_BASE}/../GetSnippet.applescript"
  PATH_PASTE = "#{PATH_BASE}/../PasteSnippet.applescript"
  PATH_ENCODE = "#{PATH_BASE}/../encoding.sh"

  # Encodes text for submission to AppleScript that loads fmxmlsnippet to the clipboard
  # @note Uses hard-coded placeholders for high-ascii characters. See PATH_ENCODE for logic.
  # @param [String] text
  # @return [String] Text with extended ascii characters escaped with placeholders
  # @example
  #   "en-dash: –".encoded_text #=> "en-dash: #:8211:#"
  def self.encode_for_applescript(text=self.to_s)
    text = text.escape_for_shell
    text.gsub!(/&(?!#[0-9]+;)/u,'&#38;') # HTML-encode ampersand
    `"#{PATH_ENCODE}" '#{text}'`
  end

  # Escapes incoming text for submission to shell
  # @todo Use native command?
  def self.escape_for_shell(text=self.to_s)
    text.gsub(/'/u,"'\\\\''")
  end

  # def paste
  #   IO.popen('pbcopy', 'w+') { |clipboard| clipboard.print self.to_s }
  #   `osascript -e 'tell application "System Events" to keystroke "v" using {command down}'`
  # end

  # Tells OS to paste supplied text at cursor. Allows TextMate bundle command to return multiple output types.
  def self.paste
    text = self.to_s
    # Open3.popen3( 'pbcopy' ) { |stdin, stdout, stderr| stdin << text }
    Open3.popen3( 'pbcopy' ) do
      |stdin, stdout, stderr|
      stdin.write(text)
      stdin.close_write
      stderr.read.split("\n").each do |line|
        puts "[parent] stderr: #{line}"
      end
    end
    `osascript -e 'tell application "System Events" to keystroke "v" using {command down}'`
  end

  # Returns FileMaker object on clipboard as text
  # @return [String] Clipboard object from FileMaker describing object in XML. Returns error message in case of error.
  def self.get
    shellScript = %Q[osascript "#{PATH_COPY}"]
    begin
      `#{shellScript}`
    rescue => e
      if FileMaker::DEBUG_ON
        puts e.message
        puts e.backtrace
      end
      raise IOError "Unrecognized clipboard data"
    end
  end

  # Loads contents of Snippet object to FileMaker's clipboard
  # @return [String,nil] XML that was loaded to the clipboard. Returns nil in case of error.
  # @todo return stderr better. See executor.rb for example.
  def self.set(object)
    begin
      text = self.escape_for_shell(object.to_xml)
      # Use xargs -0 so we can provide long strings with single quotes and spaces
      # osascript '-s o' option prints errors to stdout
      shellScript = %Q[echo '#{text}'|xargs -0 osascript -s o "#{PATH_PASTE}"]
      result = `#{shellScript}`
      result.gsub!(/\r/,"\n") if result
      if result.start_with?('Error validating XML')
        raise ArgumentError, result
      elsif result.start_with?('Error')
        raise ArgumentError, "Invalid/Unsupported string. Could be trouble with extended ascii character.\n#{result}"
      end
      return result
    end
  end

end