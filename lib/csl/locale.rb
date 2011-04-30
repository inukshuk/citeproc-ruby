module CSL
  
  class Locale
    include Support::Tree
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

    alias :style :parent

    # @param argument a language tag; or an XML node
    def initialize(argument=nil, style=nil, &block)
      case
      when argument.is_a?(Nokogiri::XML::Node)
        @language, @region = argument['lang'].split(/-/) if argument['lang']
        parse!(argument)
      
      when argument.is_a?(String) && argument.match(/^\s*<locale/)
        argument = Nokogiri::XML.parse(argument) { |config| config.strict.noblanks }.root
        @language, @region = argument['lang'].split(/-/) if argument['lang']
        parse!(argument)
      
      when argument.is_a?(String) || argument.is_a?(Symbol)
        set(argument)
      end
      
      @parent = style
      
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
      
      @options = Hash[*node.css('style-options').map(&:attributes).map { |a| a.map { |name, a| [name, a.value] } }.flatten]    
      
      @date = Hash.new([])
      ['text', 'numeric'].each do |form|
        @date[form] = node.css("date[form='#{form}'] > date-part").map do |part|
          Nodes::DatePart.new(Hash[*part.attributes.values.map { |a| [a.name, a.value] }.flatten])
        end
      end
      
      self
    end
    
    def set(tag)
      @language, @region = tag.to_s.split(/-/)
    end
    
    def tag
      [@language, @region].compact.join('-')
    end
  
    def terms
      @terms ||= Term.build
    end
    
    alias :term :terms
    
    def has_term?(term)
      terms.has_key?(term.to_s)
    end
    
    def [](term)
      terms[term.to_s]
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

    # Locales are sorted first by language, then by region; sort order is
    # alphabetical with the following exceptions: en_US (the default locale)
    # is prioritised; in case of a language-match the default region of that
    # language will be prioritised (thus, de_DE will comes before de_AT even
    # though the alphabetical order would be different).
    def <=>(other)
      Locale.sort.call(self, other)
    end
    
    def self.sort(language = nil, region = nil)
      Proc.new do |a,b|
        if a.language != b.language
          case
          when a.language == language.to_s || b.language.nil? then -1
          when b.language == language.to_s || a.language.nil? then 1
          when a.language == 'en' then -1
          when b.language == 'en' then 1
          else
            a.language <=> b.language
          end
        else
          case
          when a.region == b.region then 0
          when a.region == region.to_s || b.region.nil? then -1
          when b.region == region.to_s || a.region.nil? then 1
          when a.region == Locale.regions[a.language] then -1
          when b.region == Locale.regions[a.language] then 1
          else
            a.region <=> b.region
          end
        end
      end
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
      
      while ordinal.empty? && mod >= 1
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