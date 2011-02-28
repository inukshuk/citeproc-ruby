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
  
  # Terms are localized strings. For example, if a style specifies that the
  # term "and" should be used, the string that appears in the style output
  # depends on the locale: "and" for English, "und" for German. Terms are
  # defined using cs:term elements, child elements of cs:terms, itself a child
  # element of cs:locale. Terms are identified by the value of the name
  # attribute of cs:term. Two types of terms exist: simple terms, where the
  # content of the cs:term is the localized string, and compound terms, where
  # cs:term includes the two child elements cs:single and cs:multiple, which
  # respectively contain the singular and plural variant of the term (e.g.
  # "page" and "pages"). Some terms are defined for multiple forms. In these
  # cases, multiple cs:term element share the same value of name, but differ
  # in the value of the optional form attribute. The different forms are:
  #
  # * "long" - the default, e.g. "editor" and "editors" for the term "editor"
  # * "short" - e.g. "ed" and "eds" for the term "editor"
  # * "verb" - e.g. "edited by" for the term "editor"
  # * "verb-short" - e.g. "ed" for the term "editor"
  # * "symbol" - e.g. "§" for the term "section"
  #  
  # The plural attribute can be set to choose either the singular (value
  # "false", the default) or plural variant (value "true") of a term. In
  # addition, the form attribute can be set to select the desired term form
  # ("long" [default], "short", "verb", "verb-short" or "symbol"). If for a
  # given term the desired form does not exist, another form may be used:
  # "verb-short" reverts to "verb", "symbol" reverts to "short", and "verb"
  # and "short" both revert to "long".
  #
  class Term
    include Attributes
    
    def initialize(name)
      self.name = name
    end
      
    attr_fields %w{ name long short verb verb-short symbol }
    
    def self.build(doc)
      terms = Hash.new { |h,k| h[k] = Term.new(k) }

      doc.css('terms term').each do |t|
        terms[t['name']][t['form'] || 'long'] = t.children.map(&:content)
      end
      
      terms
    end
    
    def to_s(options={})
      term = case options['form']
        when 'verb-short' then verb_short || verb || long
        when 'symbol'     then symbol || short || long
        when 'verb'       then verb || long
        when 'short'      then short || long
        else long
      end || []
      
      options['plural'] && options['plural'] != 'false' && options['plural'].to_s != '1' ? term.last.to_s : term.first.to_s
    end
    
    def empty?
      long.nil? && short.nil? && verb.nil? && verb_short.nil? && symbol.nil?
    end
  end
  
  class Locale

    # Class Instance Variables
    @path = File.expand_path('../../../resource/locale/', __FILE__)
    @default = 'en-US'

    class << self; attr_accessor :path, :default; end    
    
    attr_reader :language, :region, :terms

    # @param argument a language tag; or an XML node
    def initialize(tag=nil)
      set(tag || Locale.default)
    end
    
    def language=(new_language)
      @language = new_language
      match_region
    end
    
    def region=(new_region)
      @region = new_region
      match_language
    end
    
    def set(tag)
      @language, @region = tag.to_s.split(/-/)
    end
    
    def tag
      [@language, @region].join('-')
    end
  
    def [](tag)
      term = @terms.map { |terms| terms[tag] }
      term.detect {|t| !t.empty?} || term.first
    end

    # @example
    # #options['punctuation-in-quotes'] => 'true'
    def options
      @options ||= Hash.new { |h,k| @doc.at_css('style-options')[k.to_s] }
    end
    
    alias :style_options :options

    # @example
    # #date(:numeric)['month']['suffix'] => '/'
    def date
      @date ||= Hash[['text', 'numeric'].map { |form|
        [form, @doc.css("date[form='#{form}'] > date-part")]
      }]
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

    # Reloads the XML file. Called automatically whenever the locale changes.
    def reload!
      match_region if @region.nil?
      match_language if @language.nil?
      
      @options, @date, @terms = nil
      @doc = Nokogiri::XML(File.open(document_path)) { |config| config.strict.noblanks }
      
      @terms = [Term.build(@doc)]
    rescue Exception => e
      CiteProc.log.error "Failed to open locale file, falling back to default: #{e.message}"
      unless tag == Locale.default
        @language, @region = Locale.default.split(/-/)
        retry
      end
    end

    # Returns an ordinalized number according to the rules specified in the
    # given locale. Does not conform to CSL 1.0 in order to work around some
    # shortcomings in the schema: this version tries several useful fall-backs
    # if there is no direct hit in the locale (e.g., if 21 is not specified,
    # we will try with 21 and then with 1).
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
      
      ordinal = self[key % number].to_s 
      ordinal = self[key % (number % 10)].to_s if ordinal.empty?
      
      options['form'] == 'ordinal' ? [number, ordinal].join : ordinal
    end

    
    private
    
    # Set region to first available region for current language.
    def match_region
      Dir.entries(Locale.path).detect { |l| l.match(%r/^[\w]+-#{@language}-([A-Z]{2})\.xml$/) }
      @region = $1
    end

    # Set language to first available language for current region.
    def match_language
      Dir.entries(Locale.path).detect { |l| l.match(%r/^[\w]+-([a-z]{2})-#{@region}\.xml$/) }
      @language = $1
    end
    
    def document_path
      File.expand_path("./locales-#{@language}-#{@region}.xml", Locale.path)
    end
     
  end
end