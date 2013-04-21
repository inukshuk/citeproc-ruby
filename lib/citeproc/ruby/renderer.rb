module CiteProc
  module Ruby

    class Renderer
      extend Forwardable

      attr_reader :locale

      def_delegator :@format, :apply, :format

      def initialize
        @locale, @format = CSL::Locale.load, Format.load
      end


      # @param item [CiteProc::CitationItem]
      # @param node [CSL::Node]
      # @return [String]
      def render(data, node)
        specialize = "render_#{node.nodename.tr('-', '_')}"
        raise ArgumentError unless respond_to?(specialize)

        format send(specialize, data, node), node
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
