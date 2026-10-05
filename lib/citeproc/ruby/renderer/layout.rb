module CiteProc
  module Ruby

    class Renderer

      private

      # Note that the layout's delimiter is used only between
      # cites in a citation, not between the layout's children.
      #
      # @param item [CiteProc::CitationItem]
      # @param node [CSL::Style::Layout]
      # @return [String]
      def render_layout(item, node)
        join node.each_child.map { |child|
          render item, child
        }.reject(&:empty?)
      end

    end

  end
end
