module CiteProc
  module Ruby
    
    class Renderer
      
      private

      # @param item [CiteProc::CitationItem]
      # @param node [CSL::Style::Choose]
      # @return [String]
      def render_choose(item, node)
        node.each_child do |child|
          return render(item, child) if child.evaluate(data)
        end
        ''
      end
      
    end
    
  end
end
