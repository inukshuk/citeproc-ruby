module CSL
  
  # Represents a cs:citation or cs:bibliography element.
  class Renderer < Node
    
    attr_fields Nodes.inheritable_name_attributes
    attr_fields %w{ delimiter-precedes-et-al }

    attr_reader :layout, :style
  
    def initialize(*args, &block)
      @style = args.detect { |argument| argument.is_a?(Style) }
      args.delete(@style) unless @style.nil?
      @parent = @style
      
      args.each do |argument|
        case          
        when argument.is_a?(String) && argument.match(/^\s*</)
          parse(Nokogiri::XML.parse(argument) { |config| config.strict.noblanks }.root)
        
        when argument.is_a?(Nokogiri::XML::Node)
          parse(argument)
        
        when argument.is_a?(Hash)
          merge!(argument)
        
        else
          CiteProc.log.warn "failed to initialize Renderer from argument #{ argument.inspect }" unless argument.nil?
        end
      end

      set_defaults
      
      yield self if block_given?
    end

    def sort(data, processor)
      sort = find_children_by_name('sort').first
      sort.nil? ? data : sort.apply(data, processor)
    end
    
    def parse(node)
      @layout = Nodes.parse(node.at_css('layout'), style)
      add_children(Node.parse(node.at_css('sort')))
    end
  
    def render(data, processor=nil)
      # TODO add support for one-off processor instance
      processor.format(process(data, processor).join(delimiter), attributes)
    rescue Exception => e
      CiteProc.log :error, "failed to render data #{ data.inspect }", e
    end  
      
    def process(data, processor)
      sort(data, processor).map do |item|
        [item['prefix'], @layout.process(item, processor), item['suffix']].compact.join(' ')
      end
    end
    
    protected
    
    def set_defaults
    end
    
  end

  class Bibliography < Renderer
    attr_fields %w{ hanging-indent second-field-align line-spacing
      entry-spacing subsequent-author-substitute }
      
  end

  class Citation < Renderer
    attr_fields %w{ collapse year-suffix-delimiter after-collapse-delimiter
      near-note-distance disambiguate-add-names disambiguate-add-given-name
      given-name-disambiguation-rule disambiguate-add-year-suffix }
    
    attr_fields %w{ delimiter suffix prefix }
    
    def initialize(*arguments, &block)
      super
      %w{ delimiter suffix prefix }.each do |attribute|
        self[attribute] = @layout.attributes.delete(attribute)
      end
    end
    
  end
end