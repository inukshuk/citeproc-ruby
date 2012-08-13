module CiteProc
  module Ruby

    class Renderer
      
      attr_reader :locale
      
      def initialize
        @locale = CSL::Locale.load
      end


      # @param item [CiteProc::CitationItem]
      # @param node [CSL::Node]
      # @return [String]
      def render(data, node)
        specialize = "render_#{node.nodename}"
        raise ArgumentError unless respond_to?(specialize)

        send specialize, data, node
      end

      def translate(name, options = {})
        locale.translate options.merge(:name => name)
      end

      def ordinalize(number, options = {})
        locale.ordinalize number, options
      end
    end

  end
end
