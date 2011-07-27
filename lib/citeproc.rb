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
# require 'ruby-debug'
# Debugger.start

require 'extensions/core'
require 'support/attributes'
require 'support/tree'

require 'csl/node'
require 'csl/term'
require 'csl/locale'
require 'csl/nodes'
require 'csl/sort'
require 'csl/renderer'
require 'csl/style'

require 'citeproc/version'
require 'citeproc/variable'
require 'citeproc/name'
require 'citeproc/date'
require 'citeproc/data'
require 'citeproc/selector'
require 'citeproc/item'
require 'citeproc/bibliography'
require 'citeproc/formatter'
require 'citeproc/processor'


require 'plugins/formats/default'

# Load filter and format plugins
Dir.glob("#{File.expand_path('..', __FILE__)}/plugins/formats/*.rb").each do |format|
  require format
end


Dir.glob("#{File.expand_path('..', __FILE__)}/plugins/filters/*.rb").each do |format|
  require format
end


# Top-level CSL utility functions

module CiteProc

  module_function
  
  def default_format; Format.default; end

  def process(*arguments, &block); Processor.process(*arguments, &block); end
  
end

module CSL
  
  module_function
  
  def default_locale
    Locale.new(Locale.default)
  end
  
  def default_style
    Style.new(Style.default)
  end
  
  def process(*arguments, &block); CiteProc.process(*arguments, &block); end
  
end
