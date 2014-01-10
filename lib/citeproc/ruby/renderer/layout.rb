module CiteProc
  module Ruby

    class Renderer

      # @param item [CiteProc::CitationItem]
      # @param node [CSL::Style::Layout]
      # @return [String]
      def render_layout(item, node)
        format node.each_child.map { |child|
          render item, child
        }.reject(&:empty?).join(node.delimiter), node
      end

    end

  end
end
