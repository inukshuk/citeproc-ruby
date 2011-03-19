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

module CSL
  
  class Sort < Node; end
  
  class SortKey < Node
    attr_fields %w{ variable macro sort names-min names-use-first names-use-last }
    
    def convert(item)
    end
    
  end
  
  # Represents a cs:citation or cs:bibliography element.
  class Renderer < Node
    
    attr_fields Nodes.inheritable_name_attributes
    attr_fields %w{ delimiter-precedes-et-al }

    attr_reader :layout, :sort_keys, :style
  
    alias :parent :style
  
    def initialize(*args, &block)
      @style = args.detect { |argument| argument.is_a?(Style) }
      args.delete(@style) unless @style.nil?
      
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
    
    def parse(node)      
      @layout = Nodes.parse(node.at_css('layout'), style)
      @sort_keys = node.css('sort key').map do |key|
        Hash[key.attributes.values.map { |a| [a.name, a.value] }]
      end
    end
  
    # :call-seq:
    # sort(items, processor) -> array
    #
    # @returns an array contining the items sorted accroding to this style's
    # sort keys.
    def sort(data, processor)
      data.sort do |a,b|
        comparison = 0
        sort_keys.each do |key|
          case
          when key.has_key?('variable')
            variable = key['variable']
            this, that = a[variable], b[variable]

          when key.has_key?('macro')
            macro = processor.style.macros[key['macro']]
            this, that = macro.process(a, processor), macro.process(b, processor) 

          else
            CiteProc.log.warn "sort key #{ key.inspect } contains no variable or macro definition."
          end

          comparison = this <=> that
          comparison = comparison ? comparison : that.nil? ? 1 : -1
        
          comparison = comparison * -1 if key['sort'] == 'descending'
          break unless comparison.zero?
        end
        
        comparison
      end
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
    
    def to_sort_key(items, processor)
      items.map do |item|
        
      end
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
    
    def initialize(node, style)
      super
      %w{ delimiter suffix prefix }.each do |attribute|
        self[attribute] = @layout.attributes.delete(attribute)
      end
    end
    
  end
end