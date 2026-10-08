module CiteProc
  module Ruby

    class Renderer

      # @param item [CiteProc::CitationItem]
      # @param node [CSL::Style::Group]
      # @return [String]
      def render_group(item, node)
        render_as_group item, node, node.delimiter
      end

      private

      # Renders the node's children with group suppression:
      # the result is empty if the children call variables
      # and ALL of them are empty; a non-empty result counts
      # as a non-empty variable for any enclosing groups.
      #
      # @param item [CiteProc::CitationItem]
      # @param node [CSL::Node]
      # @param delimiter [String, nil]
      # @return [String]
      def render_as_group(item, node, delimiter = nil)
        observer = ItemObserver.new(item.data)
        observer.start

        begin
          rendition = join(node.each_child.map { |child|
            render item, child
          }.reject(&:empty?), delimiter)
        ensure
          observer.stop
        end

        return '' if observer.skip?

        item.data.simulate_read_attribute :group, rendition unless rendition.empty?

        rendition
      end

    end

  end
end
