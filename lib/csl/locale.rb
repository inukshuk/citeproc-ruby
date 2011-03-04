#--
# CiteProc-Ruby
# Copyright (C) 2009-2011	Sylvester Keil <sylvester.keil.or.at>
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


module CSL
  
  class Locale
    include Comparable

    # Class Instance Variables
    @path = File.expand_path('../../../resource/locale/', __FILE__)
    @default = 'en-US'
    
    # Language and region defaults
    @regions = Hash.new { |hash, key| hash[key] = Locale.match_region(key) }
    @regions['en'] = 'US'
    @regions['de'] = 'DE'
    @regions['pt'] = 'PT'

    @languages = Hash.new { |hash, key| hash[key] = Locale.match_language(key) }

    class << self
      attr_accessor :path, :default, :regions, :languages
  
      # @returns first available region for current language.
      def match_region(language)
        Dir.entries(Locale.path).detect { |l| l.match(%r/^[\w]+-#{language}-([A-Z]{2})\.xml$/) }
        $1
      end

      # @returns first available language for current region.
      def match_language(region)
        Dir.entries(Locale.path).detect { |l| l.match(%r/^[\w]+-([a-z]{2})-#{region}\.xml$/) }
        $1
      end
    end
    
    
    attr_reader :language, :region

    # @param argument a language tag; or an XML node
    def initialize(argument=nil, &block)
      case
      when argument.is_a?(Nokogiri::XML::Node)
        @language, @region = argument['lang'].split(/-/)
        parse!(argument)
      
      when argument.is_a?(String) && argument.match(/^\s*<locale/)
        argument = Nokogiri::XML.parse(argument) { |config| config.strict.noblanks }.root
        @language, @region = argument['lang'].split(/-/)
        parse!(argument)
      
      when argument.is_a?(String) || argument.is_a?(Symbol)
        set(argument)
      end
      
      yield self if block_given?
    end
    
    def language=(language)
      @language = language
      @region = Locale.regions[language]
    end
    
    def region=(region)
      @region = region
      @language = Locale.languages[region]
    end
    
    def parse!(node)
      raise(ArgumentError, "expected XML node, was: #{ node.inspect }") unless node.is_a?(Nokogiri::XML::Node)
      
      @terms = Term.build(node)
      
      @options = Hash[node.css('style-options').map(&:attributes).map { |a| a.map { |name, a| [name, a.value] } }.flatten]    
      
      @date = Hash.new([])
      ['text', 'numeric'].each do |form|
        @date[form] = node.css("date[form='#{form}'] > date-part").map do |part|
          Hash[part.attributes.values.map { |a| [a.name, a.value] }]
        end
      end
      
      self
    end
    
    def set(tag)
      @language, @region = tag.to_s.split(/-/)
    end
    
    def tag
      [@language, @region].join('-')
    end
  
    def terms
      @terms ||= Term.build
    end
    
    def [](tag)
      terms[tag.to_s]
    end

    # @example
    # #options['punctuation-in-quotes'] => 'true'
    def options
      @options ||= {}
    end
    
    alias :style_options :options

    # @example
    # #date['numeric']['month']['suffix'] => '/'
    def date
      @date ||= Hash.new([])
    end
    
    # Around Alias Chains to call reload whenver locale changes
    [:language=, :region=, :set].each do |method|
      original = [:original, method].join('_')
      alias_method original, method
      define_method method do |*args|
        self.send(original, *args)
        reload!()
      end
    end

    # Reloads the XML file. Called automatically whenever language or region changes.
    def reload!
      @region = Locale.regions[@language] if @region.nil?
      @language = Locale.languages[@region] if @language.nil?

      parse!(Nokogiri::XML(File.open(document_path)) { |config| config.strict.noblanks }.root)
    rescue Exception => e
      CiteProc.log.error "Failed to open locale file, falling back to default: #{e.message}"
      CiteProc.log.debug e.backtrace[0..10].join("\n")
      
      unless tag == Locale.default
        @language, @region = Locale.default.split(/-/)
        retry
      end
    end

    def <=>(other)
      self.tag <=> other.tag
    end
    
    # Returns an ordinalized number according to the rules specified in the
    # given locale. Does not conform to CSL 1.0 in order to work around some
    # shortcomings in the schema: this version tries a useful fallback if
    # there is no direct hit in the locale (e.g., if 21 is not specified, we
    # will try with 21 and then with 1). The fallback of the long-ordinal form
    # is ordinal.
    #
    # TODO: long-ordinals may be influenced by gender in some locales
    #
    # @param number a Fixnum
    # @param options the options hash; should contain a 'form' attribute
    # @returns a string, e.g., '1st'
    #
    def ordinalize(number, options={})
      number = number.to_i
      
      options['form'] ||= 'ordinal'
      key = [options['form'], '%02d'].join('-')

      ordinal = self[key % number].to_s(options)
      mod = 100
      
      while ordinal.empty? && mod > 1
        key = 'ordinal-%02d'
        ordinal = self[key % (number % mod)].to_s(options)
        mod = mod / 10
      end
      
      key.match(/^ordinal/) ? [number, ordinal].join : ordinal
    end

    
    private
    
    def document_path
      File.expand_path("./locales-#{@language}-#{@region}.xml", Locale.path)
    end
     
  end
end