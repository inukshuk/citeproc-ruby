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

        names.reject! { |n| n[1].nil? || n[1].empty? }

        if names.empty?
          return '' unless node.has_substitute?

          # TODO substitution

        else

          resolve_editor_translator_exception! names

          names.map { |role, ns|

            # TODO

          }.join(node.delimiter)
        end
      end

      private

      def resolve_editor_translator_exception!(names)

        translator = names.detect { |role, _| role == :translator }
        return names if translator.nil?

        editor = names.detect { |role, _| role == :editor }
        return names if editor.nil?

        # TODO

        names
      end
    end

  end
end
