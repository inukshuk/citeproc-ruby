module CiteProc
  module Ruby

    class Engine < CiteProc::Engine

      @name = 'citeproc-ruby'.freeze
      @type = 'CSL'.freeze
      @version = CSL::Schema.version
      @priority = 1

      attr_reader :renderer, :style

      def initialize(*arguments)
        super(*arguments)
        @renderer = Renderer.new

        update! unless processor.nil?
      end

      def process
        raise NotImplementedByEngine
      end

      def append
        raise NotImplementedByEngine
      end

      def bibliography(selector)
        CiteProc::Bibliography.new do |b|
          items.each do |key, item|
            if selector.matches?(item) && !selector.skip?(item)
              begin
                b << renderer.render(item, style.bibliography.layout)
              rescue => e
                b.errors << [key, e]
              end
            end
          end
        end
      end

      def update_items
        raise NotImplementedByEngine
      end

      def update_uncited_items
        raise NotImplementedByEngine
      end

      def render(item, mode = :bibliography)
        case mode
        when :bibliography
          renderer.render item, style.bibliography.layout
        when :citation
          renderer.render item, style.citation.layout
        else
          raise ArgumentError, "cannot render unknown mode: #{mode.inspect}"
        end
      end

      def update!
        renderer.format = processor.options[:format]
        renderer.locale = processor.options[:locale]

        @style = CSL::Style.load processor.options[:style]
      end
    end
  end
end
