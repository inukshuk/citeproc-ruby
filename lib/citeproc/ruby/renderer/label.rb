module CiteProc
  module Ruby

    class Renderer

      # @param item [CiteProc::CitationItem]
      # @param node [CSL::Style::Label]
      # @return [String]
      def render_label(item, node)
        return '' unless node.has_variable?

        case
        when node.page?
          value, name = item.read_attribute(:page), :page
        when node.locator?
          value, name = item.locator, item.label
        else
          value, name = item.data[node.variable], node.term
        end

        value = value.to_s
        
        return '' if value.empty?

        options = node.attributes_for :form

        if node.names_label?
          # TODO pluralize if multiple names
        else
          case
          when node.always_pluralize?
            options[:plural] = true
          when node.never_pluralize?
            options[:plural] = false
          when node.number_of_pages?, node.number_of_volumes?
            options[:plural] = value.to_i > 1
          else
            options[:plural] = (/\S\s*[,&-]\s*\S|\df/ === value)
          end
        end

        translate name, options
      end

    end

  end
end
