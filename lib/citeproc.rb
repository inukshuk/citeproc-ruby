#--
# CiteProc-Ruby
# Copyright (C) 2009-2011 Sylvester Keil <sylvester.keil.or.at>
# 
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
# 
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.	See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with this program.	If not, see <http://www.gnu.org/licenses/>.
#++

$:.unshift(File.dirname(__FILE__)) unless
  $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))

require 'logging'
require 'nokogiri'


module CiteProc
  
  Log = Logging.logger[self.name]
  Log.add_appenders(Logging.appenders.stderr)
  
  Log.level = ENV.has_key?('DEBUG') ? :debug : :info
  
  def self.log; Log; end
  
end

require 'citeproc/version'

require 'csl/locale'
require 'csl/items'
require 'csl/bibliography'
require 'csl/processor'