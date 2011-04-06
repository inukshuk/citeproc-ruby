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