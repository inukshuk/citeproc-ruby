module CiteProc
  module Ruby

    class Renderer

      attr_reader :state

      def initialize(options = nil)
        @state = State.new

        unless options.nil?
          locale, format = options.values_at(:locale, :format)
          @locale, @format = CSL::Locale.load(locale), Format.load(format)
        end
      end

      def locale
        @locale ||= CSL::Locale.load
      end

      # @param item [CiteProc::CitationItem]
      # @param node [CSL::Node]
      # @return [String] the rendered and formatted string
      def render(item, node)
        raise ArgumentError, "no CSL node: #{node.inspect}" unless
          node.respond_to?(:nodename)

        specialize = "render_#{node.nodename.tr('-', '_')}"

        raise ArgumentError, "#{specialize} not implemented" unless
          respond_to?(specialize, true)

        format! send(specialize, item, node), node
      end

      # @param data [CiteProc::CitationData]
      # @param node [CSL::Style::Citation]
      # @return [String] the rendered and formatted string
      def render_citation(data, node)
        state.store! data, node

        citations = data.map do |item|
          render_single_citation item, node.layout
        end

        result = format! citations.join(node.layout.delimiter || ''), node.layout
      ensure
        state.clear! result
      end

      # @param data [CiteProc::CitationItem]
      # @param node [CSL::Style::Layout]
      # @return [String] the rendered and string
      def render_single_citation(item, node)
        # TODO author_only
        item.suppress! 'author' if item.suppress_author?

        join [item.prefix, render_layout(item, node), item.suffix].compact
      end

      # @param item [CiteProc::CitationItem]
      # @param node [CSL::Style::Bibliography]
      # @return [String] the rendered and formatted string
      def render_bibliography(item, node)
        state.store! item, node

        # TODO load item-specific locale
        result = render item, node.layout
      ensure
        state.clear! result
      end

      def render_sort(a, b, node, key)
        state.store! nil, key

        original_format = @format
        @format = Formats::Text.new

        if a.is_a?(CiteProc::Names)
          [render_name(a, node), render_name(b, node)]

        else
          # We need to clear any items that are suppressed
          # because they were used as substitutes during
          # rendering for sorting purposes!
          a_rendered = render a.cite, node
          a.suppressed.clear

          b_rendered = render b.cite, node
          b.suppressed.clear

          [a_rendered, b_rendered]
        end

      ensure
        @format = original_format
        state.clear!
      end

    end

  end
end
