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
  
  # Represents a cs:citation or cs:bibliography element.
  class Renderer
    include Attributes
    include Formatting
  
    attr_fields Nodes.inheritable_name_attributes

    attr_reader :layout, :sort_keys
  
    def initialize(node, style)
      @node = node
      @style = style
      
      @layout = Nodes.parse(node.at_css('layout'), style)
      @sort_keys = node.css('sort key').map do |key|
        Hash[key.attributes.values.map { |a| [a.name, a.value] }]
      end
    end
  
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

    def process(data, processor)
      sort(data, processor).map { |item| @layout.process(item, processor) }.join(self['delimiter'])
    end
    
  end

  class Bibliography < Renderer
    attr_fields %w{ hanging-indent second-field-align line-spacing
      entry-spacing subsequent-author-substitute }
      
    def process(data, processor)
      sort(data, processor).map { |item| @layout.process(item, processor) }
    end
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
    
    format_on :process
    
  end
end