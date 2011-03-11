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
  
  class << self
    def log(*args)
      return @log if args.empty?
      
      level, message, exception = args
      
      @log.send(level, [message, exception && exception.message || nil].compact.join(': '))
      @log.debug exception.backtrace[0,10].join("\n\t") unless exception.nil?
    end
  end
  
end

# Load debugger
require 'ruby-debug'
Debugger.start

require 'extensions/core'
require 'support/attributes'
require 'support/tree'

require 'csl/term'
require 'csl/locale'
require 'csl/nodes'
require 'csl/renderer'
require 'csl/style'

require 'citeproc/version'
require 'citeproc/variable'
require 'citeproc/name'
require 'citeproc/date'
require 'citeproc/data'
require 'citeproc/item'
require 'citeproc/bibliography'
require 'citeproc/formatter'
require 'citeproc/processor'

# Load filter and format plugins
Dir.glob("#{File.expand_path('..', __FILE__)}/plugins/formats/*.rb").each do |format|
  require format
end

require 'plugins/formats/default'

Dir.glob("#{File.expand_path('..', __FILE__)}/plugins/filters/*.rb").each do |format|
  require format
end


# Top-level CSL utility functions

module CiteProc
  
  def self.default_format; Format.default; end
  
end

module CSL
  
  def self.default_locale
    Locale.new(Locale.default)
  end
  
  def self.default_style
    Style.new(Style.default)
  end
  
end