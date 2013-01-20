module CiteProc
  module Ruby
    
    class Renderer
      
      # @param item [CiteProc::CitationItem]
      # @param node [CSL::Style::Group]
      # @return [String]
      def render_group(item, node)
        return '' unless node.has_children?
        
        observer = ItemObserver.new(item.data)
        observer.start
        
        rendition = node.each_child.map { |child|
          render item, child
        }.reject(&:empty?).join(node.delimiter)
        
        observer.stop
        return '' if observer.skip?
        
        rendition
      end


      class ItemObserver  
        attr_accessor :history, :item

        def initialize(item, history = {})
          @item, @history = item, history
        end

        def start
          item.add_observer(self)
          self
        end
        
        def stop
          item.delete_observer(self)
          self
        end
        
        def update(method, key, value)
          history[key] = value if method == :read
        end
        
        def skip?
          !history.empty? && history.values.all?(&:nil?)
        end
      end
      
    end
    
  end
end
