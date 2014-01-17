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
        raise ArgumentError, "no CSL node: #{node.inspect}" unless
          node.respond_to?(:nodename)

        specialize = "render_#{node.nodename.tr('-', '_')}"

        raise ArgumentError, "#{specialize} not implemented" unless
          respond_to?(specialize, true)

        format send(specialize, data, node), node
      end

      def format(string, node)
        return string unless @format
        @format.apply(string, node, locale)
      end

      def format=(format)
        @format = Format.load(format)
      end

      def join(list, delimiter)
        return list.join(delimiter) unless @format
        @format.join(list, delimiter)
      end

      def concat(string, suffix)
        return "#{string}#{suffix}" unless @format
        @format.concat(string, suffix)
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
