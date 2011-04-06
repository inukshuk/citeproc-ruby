require 'forwardable'

module CiteProc

  class Processor
    extend Forwardable
    
    attr_reader :style, :formatter
    
    def initialize
      @formatter = Formatter.new
      yield self if block_given?
    end

    def self.process(items, options = {})
      return '' if items.nil? || items.empty?
      
      processor = Processor.new do |p|
        p.style = options[:style] || CSL.default_style
        p.locale = options[:locale] || CSL.default_locale
        p.format = options[:format] || :default
        p.import(items)
      end

      if options[:mode].to_s.match(/cit(e|ation)/i)
        processor.cite(:all).map(&:last)
      else
        processor.bibliography.data.join
      end
    end
    
    def self.cite(items, options = {})
      process(items, options.merge(:mode => 'citation'))
    end

    
    def style=(resource)
      @style = resource.is_a?(CSL::Style) ? resource : CSL::Style.new(resource)
    end

    def format(*args); @formatter.format(*args); end
    
    def format=(format); @formatter.format = format; end
        
    def locale=(locale)
      @locale = locale.is_a?(CSL::Locale) ? locale : CSL::Locale.new(locale)
    end
    
    def locale
      @locale ||= CSL.default_locale
    end
    
    def_delegators :locale, :language, :language=, :region, :region=
    
    # @returns the abbreviations, a self-recording hash.
    def abbreviations
      @abbreviations ||= new_abbreviations
    end
    
    alias :transfrom :abbreviations
    
    def abbreviations=(abbreviations)
      @abbreviations = new_abbreviations
      add_abbreviations(abbreviations)
    end
    
    def add_abbreviations(abbreviations)
      abbreviations.keys.each do |list|
        abbreviations[list].keys.each do |category|
          abbreviations[list][category].each_pair do |long, short|
            self.abbreviations[list] ||= new_self_recording_hash
            self.abbreviations[list][category][long] = short
          end
        end
      end
    end
        
    def abbreviate(category, name, list='default')
      self.abbreviations[list][category][name]
    end
    
    def items
      @items ||= {}
    end
    
    def import(items)
      # TODO assign default ids if no id
      items = to_a(items)
      items.each do |item|
        item = Item.new(item)
        self.items[item['id'].to_s] = item
      end
    end
    
    def bibliography(selector = :all)
      data = items.values.select(&Selector.new(selector)).map { |i| { 'id' => i.id } }
      data = CitationData.new(data).populate!(items)
      
      data = style.bibliography.process(data, self)
      Bibliography.new(data)
    end
    

    #
    # @param data Symbol :all / or id of item
    # @param data String  id of item
    # @param data Array list of ids or citation data
    # @param data Hash citation data or citation items
    #
    # @returns a list of lists; [[1, 'Doe, 2000, p. 1'], ...]
    #
    def cite(data)
      data = extract_citation_data(data)

      data.populate!(items)
      citation = style.citation.render(data, self)
      
      [[register(citation), citation]]
    end

    def nocite(ids, options={})
      @bibliography + to_a(ids).map { |id| items[id] }
    end

    alias :make_bibliography :bibliography
    alias :update_items :cite
    alias :update_uncited_items :nocite
    
        
    private
    
    def register(id)
      1
    end
    
    def to_a(attribute)
      attribute.is_a?(Array) ? attribute : [attribute]
    end
    
    # @returns a citation data object
    def extract_citation_data(argument)
      case
      when argument == :all
        argument = items.keys.map { |id| { 'id' => id } }
              
      when items.has_key?(argument.to_s)
        argument = { 'id' => argument.to_s }

      when argument.is_a?(Array) && items.has_key?(argument.first.to_s)
        argument = argument.map { |id| { 'id' => id } }
      
      end

      CitationData.new(argument)
    end
    
    def new_abbreviations
      { 'default' => new_self_recording_hash }
    end
    
    def new_self_recording_hash
      Hash.new { |h,k| h[k] = Hash.new { |h,k| h[k] = k } }
    end
  end
  
end