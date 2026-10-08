module CiteProc
  module Ruby

    class Renderer

      private

      # @param item [CiteProc::CitationItem]
      # @param node [CSL::Style::Macro]
      # @return [String]
      def render_macro(item, node)
        render_as_group item, node
      end

    end

  end
end
