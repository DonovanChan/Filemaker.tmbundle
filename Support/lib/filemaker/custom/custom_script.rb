#!/usr/bin/ruby -KU
# encoding: UTF-8
#
# custom_script.rb - custom logic for manipulating FileMaker scripts.
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

# Handles actions specific to scripts. Switch out this module to suite your own conventions.
module FileMaker::FMScriptCustom

  # here = File.dirname(__FILE__)

  # Delimiter prepended to parameters in script names and documentation to indicate they're optional
  $paramDelimOptional = "-"
  # Delimiter used in script names and documentation to indicate "or" relationship between parameters
  $paramDelimOr = "|"

  # Provides default mapping between string and local variable
  # @param [String] name Variable name
  # @return [String] Full variable name
  # @example
  #   puts param_to_var('contact') # => '$_contact'
  def self.param_to_var(name)
    return "$_#{name}"
  end

  # Returns default calculation for extracting script parameters
  # @param [String] name Name of FileMaker script parameter
  # @return [String] FileMaker calculation used to extract parameter. Strips optionality indicator declared in $paramDelimitOptional.
  # @example
  #   puts param_extract('-id') # => '#P ( "ID" )'
  def self.param_extract(name)
    return '#P ( "' + param_clean(name).upcase + '" )'
  end

  # Returns true if named script parameter is optional
  # @param [String] name Name of parameter (including optionality indicator prefix defined in $paramDelimOptional)
  # @return [true, false]
  def self.param_is_optional(name)
    name.start_with?($paramDelimOptional)
  end

  # Strips extraneous indicators from parameter name
  # @param [String] name Name of parameter (including optionality indicator prefix defined in $paramDelimOptional)
  def self.param_clean(name)
    return nil if !name
    res = name.dup
    res.slice!(/#{$paramDelimOptional}/u)
    res
  end

  # Returns array of script parameters from string
  # @param [String] scriptName String containing script input parameters
  # @return [Array] Each input parameter
  # @example
  #   scriptName = 'script ( param1 ; -optionalParam ) : output'
  #   puts parse_params(scriptName) # => '["param1","-optionalParam"]'
  def self.parse_params(scriptName)
    params = scriptName.match(/\((.+)\)/)
    return nil unless params
    params[1].split(/;/).map{|x| x.strip}
  end

  # Returns array of script result parameters in text
  # @param [String] scriptName String containing result parameters
  # @return [Array] Each output parameter
  # @example
  #   scriptName = 'script ( param1 ; -optionalParam ) : output'
  #   puts parse_results(scriptName) # => '["output"]'
  def self.parse_results(scriptName)
    params = scriptName.match(/:(.*$)/)
    return nil unless params
    params[1].split(/;/).map{|x| x.strip}
  end

end

module FileMaker
  include FileMaker::FMScriptCustom
end