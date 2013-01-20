module CiteProc
  module Ruby
    
    class Renderer
      
      private

      # @param item [CiteProc::CitationItem]
      # @param node [CSL::Style::Choose]
      # @return [String]
      def render_choose(item, node)
        return '' unless node.has_children?
        
        node.each_child do |child|
          return render_block(item, child) if evaluate_block(item, child)
        end

        '' # no block was rendered
      end
      
      # @param item [CiteProc::CitationItem]
      # @param node [CSL::Style::Choose::Block]
      # @return [String]
      def render_block(item, node)
        return '' unless node.has_children?
        
        node.each_child.map { |child|
          render item, child
        }.join('')
      end

      def evaluate_block(item, block)
        # case
        # when
        # else
        # end
      end
    end
    
  end
end
