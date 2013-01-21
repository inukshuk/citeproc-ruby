module CiteProc
  module Ruby

    class Renderer

      # @param item [CiteProc::CitationItem]
      # @param node [CSL::Style::Choose]
      # @return [String]
      def render_choose(item, node)
        return '' unless node.has_children?

        node.each_child do |child|
          return render_block(item, child) if evaluates?(item, child)
        end

        '' # no block was rendered
      end

      # @param item [CiteProc::CitationItem]
      # @param node [CSL::Style::Choose::Block]
      # @return [String]
      def render_block(item, node)
        return '' unless node.has_children?

        node.each_child.map { |child|
          render item, child
        }.join('')
      end


      # Evaluates the conditions of the passed-in Choose::Block
      # against the passed-in CitationItem using the Block's matcher.
      #
      # @param item [CiteProc::CitationItem]
      # @param node [CSL::Style::Choose::Block]
      #
      # @return [Boolean] whether or not
      def evaluates?(item, node)

        # subtle: else-nodes have no conditions. since the default
        # matcher :all? returns true for an empty list we do not
        # need to check for an else node specifically.

        # return true if node.nodename == 'else'

        node.conditions.send(node.matcher) do |type, value|
          case type
          when :disambiguate
            false # not implemented yet

          when :'is-numeric'
            v = item.data[value]
            v.respond_to?(:numeric?) && v.numeric?

          when :'is-uncertain-date'
            v = item.data[value]
            v.respond_to?(:uncertain?) && v.uncertain?

          when :locator
            value.to_s == item.locator.to_s

          when :position
            false # not implemented yet

          when :type
            value.to_s == item.data[:type].to_s

          when :variable
            item.data.attribute?(value)

          else
            warn "unknown condition type: #{type}"
            false
          end
        end
      end
    end

  end
end
