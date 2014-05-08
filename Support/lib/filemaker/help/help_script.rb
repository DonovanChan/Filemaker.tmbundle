#!/System/Library/Frameworks/Ruby.framework/Versions/1.8/usr/bin/ruby -KU
# encoding: UTF-8
#
# help_script.rb
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

# Accesses FileMaker help documentation
module FileMaker::FMHelp

  fmbase = HELP_BASE_URL
  SCRIPT_INDEX_URL = fmbase + 'help_script_cat.34.1.html'

  # Searches SCRIPT_URLS for key matching query. If no match is found, takes first script beginning with same string. Returns url to page for that entry. Ignores case and whitespace in query.
  #   get_script_doc('Show Custom Dialog') = 'http://www.filemaker.com/12help/html/scripts_ref2.37.57.html#1029316'
  #   get_script_doc('showcustom') = 'http://www.filemaker.com/12help/html/scripts_ref2.37.57.html#1029316'
  def self.get_script_doc(query)
    return nil if query.empty?
    query = query.dup
    query.gsub!(/\s/,'')
    query.downcase!
    SCRIPT_URLS[query] || SCRIPT_URLS.select{|key,value| key.start_with?(query) }.first.to_a[1] #|| SCRIPT_INDEX_URL
  end

  # Generated using following shell command
  #   ruby -e 'STDOUT << "SCRIPT_URLS = {\n" << `curl -s http://www.filemaker.com/help/13/fmp/en/html/help_script_alpha.html`.force_encoding("ISO-8859-1").encode("utf-8", replace: nil).scan(%r{<div class=".*?"><a href="(.*?)" name=".*?">(.*?)</a></div>}).map { |e| "  \"#{e[1].downcase.gsub(/\s/, nil.to_s).gsub(/\(.+?\)/, nil.to_s)}\"".ljust(30) + " => fmbase + \"#{e[0]}\"" }.join(",\n") << "\n}\n"' | pbcopy
  SCRIPT_URLS = {
    "addaccount"                 => fmbase + "scripts_ref2.37.28.html#1028463",
    "adjustwindow"               => fmbase + "scripts_ref2.37.5.html#1027682",
    "allowformattingbar"         => fmbase + "scripts_ref2.37.58.html#1029376",
    "allowuserabort"             => fmbase + "scripts_ref1.36.13.html#1028071",
    "arrangeallwindows"          => fmbase + "scripts_ref2.37.7.html#1027755",
    "beep"                       => fmbase + "scripts_ref2.37.59.html#1029406",
    "changepassword"             => fmbase + "scripts_ref2.37.31.html#1028557",
    "checkfoundset"              => fmbase + "scripts_ref2.37.37.html#1028756",
    "checkrecord"                => fmbase + "scripts_ref2.37.36.html#1028732",
    "checkselection"             => fmbase + "scripts_ref2.37.35.html#1028707",
    "clear"                      => fmbase + "scripts_ref1.36.34.html#1028828",
    "closefile"                  => fmbase + "scripts_ref2.37.19.html#1028131",
    "closewindow"                => fmbase + "scripts_ref2.37.4.html#1027655",
    "comment"                    => fmbase + "scripts_ref2.37.72.html#1029930",
    "commitrecords/requests"     => fmbase + "scripts_ref1.36.66.html#1030005",
    "constrainfoundset"          => fmbase + "scripts_ref1.36.78.html#1030449",
    "convertfile"                => fmbase + "scripts_ref2.37.20.html#1028165",
    "copy"                       => fmbase + "scripts_ref1.36.32.html#1028763",
    "copyallrecords/requests"    => fmbase + "scripts_ref1.36.68.html#1030065",
    "copyrecord/request"         => fmbase + "scripts_ref1.36.67.html#1030036",
    "correctword"                => fmbase + "scripts_ref2.37.38.html#1028780",
    "cut"                        => fmbase + "scripts_ref1.36.31.html#1028732",
    "deleteaccount"              => fmbase + "scripts_ref2.37.29.html#1028496",
    "deleteallrecords"           => fmbase + "scripts_ref1.36.63.html#1029908",
    "deleteportalrow"            => fmbase + "scripts_ref1.36.62.html#1040403",
    "deleterecord/request"       => fmbase + "scripts_ref1.36.61.html#1029817",
    "dialphone"                  => fmbase + "scripts_ref2.37.61.html#1068256",
    "duplicaterecord/request"    => fmbase + "scripts_ref1.36.60.html#1029782",
    "edituserdictionary"         => fmbase + "scripts_ref2.37.41.html#1028857",
    "else"                       => fmbase + "scripts_ref1.36.8.html#1027875",
    "elseif"                     => fmbase + "scripts_ref1.36.7.html#1027828",
    "enableaccount"              => fmbase + "scripts_ref2.37.32.html#1028599",
    "endif"                      => fmbase + "scripts_ref1.36.9.html#1027908",
    "endloop"                    => fmbase + "scripts_ref1.36.12.html#1028031",
    "enterbrowsemode"            => fmbase + "scripts_ref1.36.26.html#1028589",
    "enterfindmode"              => fmbase + "scripts_ref1.36.27.html#1028614",
    "enterpreviewmode"           => fmbase + "scripts_ref1.36.28.html#1028645",
    "executesql"                 => fmbase + "scripts_ref2.37.69.html#1029790",
    "exitapplication"            => fmbase + "scripts_ref2.37.74.html#1029988",
    "exitloopif"                 => fmbase + "scripts_ref1.36.11.html#1027979",
    "exitscript"                 => fmbase + "scripts_ref1.36.4.html#1027697",
    "exportfieldcontents"        => fmbase + "scripts_ref1.36.57.html#1029659",
    "exportrecords"              => fmbase + "scripts_ref1.36.70.html#1030181",
    "extendfoundset"             => fmbase + "scripts_ref1.36.79.html#1030473",
    "findmatchingrecords"        => fmbase + "scripts_ref1.36.77.html#1053933",
    "flushcachetodisk"           => fmbase + "scripts_ref2.37.73.html#1029957",
    "freezewindow"               => fmbase + "scripts_ref2.37.8.html#1027779",
    "gotofield"                  => fmbase + "scripts_ref1.36.23.html#1028490",
    "gotolayout"                 => fmbase + "scripts_ref1.36.18.html#1028245",
    "gotonextfield"              => fmbase + "scripts_ref1.36.24.html#1028527",
    "gotoobject"                 => fmbase + "scripts_ref1.36.22.html#1028450",
    "gotoportalrow"              => fmbase + "scripts_ref1.36.21.html#1028409",
    "gotopreviousfield"          => fmbase + "scripts_ref1.36.25.html#1028558",
    "gotorecord/request/page"    => fmbase + "scripts_ref1.36.19.html#1028306",
    "gotorelatedrecord"          => fmbase + "scripts_ref1.36.20.html#1028356",
    "haltscript"                 => fmbase + "scripts_ref1.36.5.html#1027734",
    "if"                         => fmbase + "scripts_ref1.36.6.html#1027769",
    "importrecords"              => fmbase + "scripts_ref1.36.69.html#1030099",
    "insertaudio/video"          => fmbase + "scripts_ref1.36.52.html#1056339",
    "insertcalculatedresult"     => fmbase + "scripts_ref1.36.43.html#1029148",
    "insertcurrentdate"          => fmbase + "scripts_ref1.36.47.html#1039436",
    "insertcurrenttime"          => fmbase + "scripts_ref1.36.48.html#1029303",
    "insertcurrentusername"      => fmbase + "scripts_ref1.36.49.html#1029335",
    "insertfile"                 => fmbase + "scripts_ref1.36.54.html#1029502",
    "insertfromindex"            => fmbase + "scripts_ref1.36.44.html#1029190",
    "insertfromlastvisited"      => fmbase + "scripts_ref1.36.45.html#1029230",
    "insertfromurl"              => fmbase + "scripts_ref1.36.46.html#1058549",
    "insertpdf"                  => fmbase + "scripts_ref1.36.53.html#1056421",
    "insertpicture"              => fmbase + "scripts_ref1.36.50.html#1029375",
    "insertquicktime"            => fmbase + "scripts_ref1.36.51.html#1029421",
    "inserttext"                 => fmbase + "scripts_ref1.36.42.html#1029106",
    "installmenuset"             => fmbase + "scripts_ref2.37.63.html#1029502",
    "installontimerscript"       => fmbase + "scripts_ref1.36.16.html#1044171",
    "installplug-infile"         => fmbase + "scripts_ref2.37.62.html#1029468",
    "loop"                       => fmbase + "scripts_ref1.36.10.html#1027932",
    "modifylastfind"             => fmbase + "scripts_ref1.36.80.html#1030496",
    "move/resizewindow"          => fmbase + "scripts_ref2.37.6.html#1027715",
    "newfile"                    => fmbase + "scripts_ref2.37.17.html#1028069",
    "newrecord/request"          => fmbase + "scripts_ref1.36.59.html#1029754",
    "newwindow"                  => fmbase + "scripts_ref2.37.2.html#1027577",
    "omitmultiplerecords"        => fmbase + "scripts_ref1.36.84.html#1030610",
    "omitrecord"                 => fmbase + "scripts_ref1.36.83.html#1030580",
    "openeditsavedfinds"         => fmbase + "scripts_ref2.37.43.html#1042740",
    "openfile"                   => fmbase + "scripts_ref2.37.18.html#1028090",
    "openfileoptions"            => fmbase + "scripts_ref2.37.45.html#1028964",
    "openfind/replace"           => fmbase + "scripts_ref2.37.52.html#1029097",
    "openhelp"                   => fmbase + "scripts_ref2.37.53.html#1029123",
    "openmanagecontainers"       => fmbase + "scripts_ref2.37.46.html#1028989",
    "openmanagedatasources"      => fmbase + "scripts_ref2.37.48.html#1029026",
    "openmanagedatabase"         => fmbase + "scripts_ref2.37.47.html#1051759",
    "openmanagelayouts"          => fmbase + "scripts_ref2.37.49.html#1042819",
    "openmanagescripts"          => fmbase + "scripts_ref2.37.50.html#1042893",
    "openmanagevaluelists"       => fmbase + "scripts_ref2.37.51.html#1029061",
    "openpreferences"            => fmbase + "scripts_ref2.37.44.html#1042783",
    "openrecord/request"         => fmbase + "scripts_ref1.36.64.html#1029942",
    "openremote"                 => fmbase + "scripts_ref2.37.54.html#1029149",
    "opensharing"                => fmbase + "scripts_ref2.37.55.html#1029205",
    "openurl"                    => fmbase + "scripts_ref2.37.65.html#1029602",
    "paste"                      => fmbase + "scripts_ref1.36.33.html#1028791",
    "pause/resumescript"         => fmbase + "scripts_ref1.36.3.html#1027656",
    "performapplescript(macos)"  => fmbase + "scripts_ref2.37.68.html#1029745",
    "performfind"                => fmbase + "scripts_ref1.36.75.html#1030378",
    "performfind/replace"        => fmbase + "scripts_ref1.36.37.html#1028916",
    "performquickfind"           => fmbase + "scripts_ref1.36.76.html#1048059",
    "performscript"              => fmbase + "scripts_ref1.36.2.html#1051802",
    "print"                      => fmbase + "scripts_ref2.37.26.html#1028386",
    "printsetup"                 => fmbase + "scripts_ref2.37.25.html#1028361",
    "recoverfile"                => fmbase + "scripts_ref2.37.24.html#1028328",
    "refreshwindow"              => fmbase + "scripts_ref2.37.9.html#1027804",
    "re-login"                   => fmbase + "scripts_ref2.37.33.html#1028631",
    "relookupfieldcontents"      => fmbase + "scripts_ref1.36.56.html#1029621",
    "replacefieldcontents"       => fmbase + "scripts_ref1.36.55.html#1029581",
    "resetaccountpassword"       => fmbase + "scripts_ref2.37.30.html#1028526",
    "revertrecord/request"       => fmbase + "scripts_ref1.36.65.html#1029979",
    "saveacopyas"                => fmbase + "scripts_ref2.37.23.html#1028294",
    "saverecordsasexcel"         => fmbase + "scripts_ref1.36.71.html#1030230",
    "saverecordsaspdf"           => fmbase + "scripts_ref1.36.72.html#1030275",
    "saverecordsassnapshotlink"  => fmbase + "scripts_ref1.36.73.html#1048226",
    "scrollwindow"               => fmbase + "scripts_ref2.37.10.html#1027834",
    "selectall"                  => fmbase + "scripts_ref1.36.36.html#1028890",
    "selectdictionaries"         => fmbase + "scripts_ref2.37.40.html#1028833",
    "selectwindow"               => fmbase + "scripts_ref2.37.3.html#1027618",
    "sendddeexecute(windows)"    => fmbase + "scripts_ref2.37.67.html#1029704",
    "sendevent(macos)"           => fmbase + "scripts_ref2.37.70.html#1029843",
    "sendevent(windows)"         => fmbase + "scripts_ref2.37.71.html#1029888",
    "sendmail"                   => fmbase + "scripts_ref2.37.66.html#1029642",
    "seterrorcapture"            => fmbase + "scripts_ref1.36.14.html#1028105",
    "setfield"                   => fmbase + "scripts_ref1.36.39.html#1029024",
    "setfieldbyname"             => fmbase + "scripts_ref1.36.40.html#1042347",
    "setmulti-user"              => fmbase + "scripts_ref2.37.21.html#1028219",
    "setnextserialvalue"         => fmbase + "scripts_ref1.36.41.html#1047759",
    "setselection"               => fmbase + "scripts_ref1.36.35.html#1028863",
    "setusesystemformats"        => fmbase + "scripts_ref2.37.22.html#1028258",
    "setvariable"                => fmbase + "scripts_ref1.36.15.html#1044136",
    "setwebviewer"               => fmbase + "scripts_ref2.37.64.html#1051268",
    "setwindowtitle"             => fmbase + "scripts_ref2.37.13.html#1027925",
    "setzoomlevel"               => fmbase + "scripts_ref2.37.14.html#1027954",
    "showallrecords"             => fmbase + "scripts_ref1.36.81.html#1030525",
    "showcustomdialog"           => fmbase + "scripts_ref2.37.57.html#1029316",
    "showomittedonly"            => fmbase + "scripts_ref1.36.82.html#1030554",
    "show/hidetextruler"         => fmbase + "scripts_ref2.37.12.html#1027893",
    "show/hidetoolbars"          => fmbase + "scripts_ref2.37.11.html#1027859",
    "sortrecords"                => fmbase + "scripts_ref1.36.85.html#1030639",
    "sortrecordsbyfield"         => fmbase + "scripts_ref1.36.87.html#1053864",
    "speak(macos)"               => fmbase + "scripts_ref2.37.60.html#1029432",
    "spellingoptions"            => fmbase + "scripts_ref2.37.39.html#1028808",
    "undo/redo"                  => fmbase + "scripts_ref1.36.30.html#1028704",
    "unsortrecords"              => fmbase + "scripts_ref1.36.86.html#1053858",
    "viewas"                     => fmbase + "scripts_ref2.37.15.html#1027985"
  }

end