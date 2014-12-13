#!/usr/bin/ruby -KU
# encoding: UTF-8
#
# help_function_external.rb
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

# Accesses help documentation for FileMaker-related products
module FileMaker::FMHelp

  scbase = "http://www.360works.com/plugins/SuperContainer/plugin-documentation.html"

  # Searches EXTERNAL_FUNCTION_URLS for key matching query or containing query within '(' and ')'. Returns url to page for that entry. Ignores case and whitespace in query.
  #   get_function_doc('currenttime') = 'http://www.filemaker.com/12help/html/func_ref2.32.24.html#1052625'
  #   get_function_doc('Get(CurrentTime)') = 'http://www.filemaker.com/12help/html/func_ref2.32.24.html#1052625'
  def self.get_external_function_doc(query)
    query.gsub!(/\s/,'')
    query.downcase!
    EXTERNAL_FUNCTION_URLS[query] || EXTERNAL_FUNCTION_URLS.select{|key,value| key =~ /\(#{query}\)/ }.first.to_a[1]
  end

  EXTERNAL_FUNCTION_URLS = {
    "fmsauc_version"             => "file:///" + ENV["TM_BUNDLE_SUPPORT"] + "/AutoUpdate.html#FMSAUC_Version",
    "fmsauc_findplugin"          => "file:///" + ENV["TM_BUNDLE_SUPPORT"] + "/AutoUpdate.html#FMSAUC_FindPlugin",
    "fmsauc_updateplugin"        => "file:///" + ENV["TM_BUNDLE_SUPPORT"] + "/AutoUpdate.html#FMSAUC_UpdatePlugin",

    "sdialog_version"             => "file:///" + ENV["TM_BUNDLE_SUPPORT"] + "/SimpleDialog.html#SDialog_Version",
    "sdialog_register"            => "file:///" + ENV["TM_BUNDLE_SUPPORT"] + "/SimpleDialog.html#SDialog_Register",
    "sdialog_inputdialog"         => "file:///" + ENV["TM_BUNDLE_SUPPORT"] + "/SimpleDialog.html#SDialog_InputDialog",
    "sdialog_progressdialog"      => "file:///" + ENV["TM_BUNDLE_SUPPORT"] + "/SimpleDialog.html#SDialog_ProgressDialog",
    "sdialog_setcalculation"      => "file:///" + ENV["TM_BUNDLE_SUPPORT"] + "/SimpleDialog.html#SDialog_SetCalculation",
    "sdialog_get"                 => "file:///" + ENV["TM_BUNDLE_SUPPORT"] + "/SimpleDialog.html#SDialog_Get",
    "sdialog_set"                 => "file:///" + ENV["TM_BUNDLE_SUPPORT"] + "/SimpleDialog.html#SDialog_Set",

    "scclearlocalcache"          => scbase + "#SCClearLocalCache",
    "scdelete"                   => scbase + "#SCDelete",
    "scdeletelocalfile"          => scbase + "#SCDeleteLocalFile",
    "scdownload"                 => scbase + "#SCDownload",
    "scgetcontainer"             => scbase + "#SCGetContainer",
    "scgetfileurl"               => scbase + "#SCGetFileURL",
    "scgetfolderurl"             => scbase + "#SCGetFolderURL",
    "scgetinfo"                  => scbase + "#SCGetInfo",
    "sclasterror"                => scbase + "#SCLastError",
    "scmove"                     => scbase + "#SCMove",
    "scmovelocalfile"            => scbase + "#SCMoveLocalFile",
    "scscandirectory"            => scbase + "#SCScanDirectory",
    "scsetbaseurl"               => scbase + "#SCSetBaseURL",
    "scsetcontainer"             => scbase + "#SCSetContainer",
    "scversion"                  => scbase + "#SCVersion",

  }

end