module CiteProc
  module Ruby

    class Renderer

      # @param item [CiteProc::CitationItem]
      # @param node [CSL::Style::Names]
      # @return [String]
      def render_names(item, node)
        return '' unless node.has_variable?

        names = node.variable.split(/\s+/).map do |role|
          [role.to_sym, item.data[role]]
        end

        resolve_editor_translator_exception names


      end

      # @param name [CiteProc::Name]
      # @param node [CSL::Style::Name]
      # @return [String]
      def render_name(name, node)
      end

      private

      def resolve_editor_translator_exception(names)
        editor, translator = names[:editor], names[:translator]

        if translator && translator == editor
          names.delete :editor
          names.delete :translator

          names[:editortranslator] = editor
        end

        names
      end
    end

  end
end
