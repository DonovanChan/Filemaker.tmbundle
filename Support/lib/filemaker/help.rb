#!/System/Library/Frameworks/Ruby.framework/Versions/1.8/usr/bin/ruby -KU
# encoding: UTF-8
#
# help.rb - accessing FileMaker help docs
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

# Accesses FileMaker help documentaiton
module FileMaker::FMHelp

  HELP_BASE_URL = 'http://www.filemaker.com/help/13/fmp/en/html/'
  REFERENCE_URL = 'http://www.filemaker.com/help/13/fmp/en/html/part5.html'
  PATH_BASE = File.dirname(__FILE__)

  require "#{PATH_BASE}/help/help_error.rb"
  require "#{PATH_BASE}/help/help_function.rb"
  require "#{PATH_BASE}/help/help_function_external.rb"
  require "#{PATH_BASE}/help/help_script.rb"

  def self.prompt_for_query (message='',query='')
    message ||= 'What function/script step/error would you like to look up?'
    res, func = %x{ "$TM_SUPPORT_PATH/bin/CocoaDialog.app/Contents/MacOS/CocoaDialog" \
      inputbox --float --title 'Open FileMaker 12 Documentation' \
      --informative-text '#{message}' \
      --text '#{query}' --button1 'Lookup' --button2 'Cancel' \
      --button3 'Show Index'
    }.split("\n")
    case res.to_i
      when 1 then self.get_doc(func.to_s)
      when 2 then abort "<script>window.close()</script>"
      when 3 then REFERENCE_URL
    end
  end

  def self.get_doc(query)
    self.get_function_doc(query) ||
      self.get_script_doc(query) ||
      self.get_error_doc(query) ||
      REFERENCE_URL
  end

  def self.get_doc_or_prompt(query)
    return self.prompt_for_query('',query.to_s) unless query
    self.get_function_doc(query.to_s) ||
      self.get_script_doc(query.to_s) ||
      self.get_error_doc(query.to_s) ||
      self.prompt_for_query("Documentation not found for \"#{query.to_s}\". Please revise your search or try browsing from the index.",query.to_s)
  end

end