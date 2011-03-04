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

require 'open-uri'

require 'logging'
require 'nokogiri'
require 'json'

#require 'activesupport'

require 'unicode_utils/upcase'
require 'unicode_utils/downcase'

module CiteProc

  @log = Logging.logger[self.name]
  @log.add_appenders(Logging.appenders.stderr)
  
  @log.level = ENV.has_key?('DEBUG') ? :debug : :info
  
  class << self; attr_reader :log; end
  
end

# Load debugger
require 'ruby-debug'
Debugger.start

require 'extensions/core'
require 'extensions/attributes'

require 'csl/term'
require 'csl/locale'
require 'csl/formatting'
require 'csl/nodes'
require 'csl/renderer'
require 'csl/style'

# load available output formats
Dir.glob("#{File.expand_path('..', __FILE__)}/csl/formats/*.rb").each do |format|
  require format
end

require 'citeproc/version'
require 'citeproc/variables'
require 'citeproc/data'
require 'citeproc/item'
require 'citeproc/bibliography'
require 'citeproc/processor'

# load available input filters
Dir.glob("#{File.expand_path('..', __FILE__)}/citeproc/filters/*.rb").each do |format|
  require format
end