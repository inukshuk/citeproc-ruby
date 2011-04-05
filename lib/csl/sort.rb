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
  
  class Sort < Node
    attr_children 'key'

    alias :keys :key
    
    def sort(items, processor)
      items.sort do |a,b|
        comparison = 0
        keys.each do |key|
          this, that = key.convert(a, processor), key.convert(b, processor)

          comparison = this <=> that
          comparison = comparison * -1 if comparison && key.descending?
          
          comparison = comparison ? comparison : that.nil? ? -1 : 1
        
          break unless comparison.zero?
        end
        
        comparison
      end
    end
    
    alias :apply :sort
    
  end
  
  class Key < Node
    attr_fields %w{ variable macro sort names-min names-use-first names-use-last }
    
    def convert(item, processor)
      case
      when has_variable?
        item[variable]
      when has_macro?
        processor.style.macros[macro].process(item, processor)
      else
        CiteProc.log.warn "sort key #{ inspect } contains no variable or macro definition."
        item
      end
    end
    
    def ascending?; !descending?; end
    
    def descending?
      has_sort? && sort == 'descending'
    end
    
  end
  
end