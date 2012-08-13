module CiteProc
  module Ruby

    class Renderer

      # @param item [CiteProc::CitationItem]
      # @param node [CSL::Style::Text]
      # @return [String]
      def render_text(item, node)
        case
        when node.has_variable?
          # TODO abbreviate?
          # TODO page range
          item.data.variable(node.variable, node.variable_options).to_s

        when node.has_macro?
          render item, node.macro

        when node.has_term?
          translate node.term_options

        else
          node.value.to_s
        end
      end

    end

  end
end
