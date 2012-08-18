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
          value, name = item.read_attribute(:page), node.variable
        when node.locator?
          value, name = item.locator, item.label
        else
          value, node = item.data[node.variable], node.variable
        end

        value = value.to_s
        
        return '' if value.empty?

        options = node.attributes_for :form

        case
        when node.always_pluralize?
          options[:plural] = true
        when node.never_pluralize?
          options[:plural] = true
        else
          options[:plural] = pluralize?(value)
        end

        translate name, options
      end


      def pluralize?(string)
        !!(string.to_s =~ /\S\s*[,&-]\s*\S|\df/)
      end
    end

  end
end
