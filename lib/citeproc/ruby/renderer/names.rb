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

            ns = render_name ns, node.name || CSL::Style::Name.new

            if node.has_label?
              # TODO
            end

          }.join(node.delimiter)
        end
      end

      # @param item [CiteProc::Names]
      # @param node [CSL::Style::Name]
      # @return [String]
      def render_name(names, node)

        delimiter = node.delimiter

        connector = node.connector
        connector = translate(connector) if connector == 'text'

        rendition = case
          when node.trucate?(names)
            truncated = node.truncate(names)

            if node.delimiter_precedes_last?(truncated)
              conncector = [delimiter, connector].compact.join('')
            end
            
            if node.ellipsis? && names.length - truncated.length > 1
              
            else
              
            end

          when names.length < 2
            
          else
            if node.delimiter_precedes_last?(names)
              conncector = [delimiter, connector].compact.join('')
            end
            
          end
        
        format rendition, node
      end

      def render_individual_name(name, node)
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
