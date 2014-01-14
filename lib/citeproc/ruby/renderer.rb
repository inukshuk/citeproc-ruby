module CiteProc
  module Ruby

    class Renderer
      attr_reader :locale

      def initialize(options = nil)
        if options.nil?
          @locale, @format = CSL::Locale.load, Format.load
        else
          locale, format = options.values_at(:locale, :format)
          @locale, @format = CSL::Locale.load(locale), Format.load(format)
        end
      end


      # @param item [CiteProc::CitationItem]
      # @param node [CSL::Node]
      # @return [String]
      def render(data, node)
        specialize = "render_#{node.nodename.tr('-', '_')}"
        raise ArgumentError unless respond_to?(specialize, true)

        format send(specialize, data, node), node
      end

      def format(string, node)
        return string unless @format
        @format.apply(string, node, locale)
      end

      def format=(format)
        @format = Format.load(format)
      end

      def locale=(locale)
        @locale = CSL::Locale.load(locale)
      end

      def translate(name, options = {})
        locale.translate(name, options).to_s
      end

      def ordinalize(number, options = {})
        locale.ordinalize(number, options)
      end

			def romanize(number)
				CiteProc::Number.romanize(number)
			end
    end

  end
end
