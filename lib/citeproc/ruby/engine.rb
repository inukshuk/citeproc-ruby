module CiteProc
  module Ruby

    class Engine < CiteProc::Engine

      include SortItems

      @name = 'citeproc-ruby'.freeze
      @type = 'CSL'.freeze
      @version = CSL::Schema.version
      @priority = 1

      attr_reader :renderer, :style

      def_delegators :renderer,
        :format, :format=, :locale, :locale=

      def initialize(*arguments)
        super(*arguments)
        @renderer = Renderer.new

        update! unless processor.nil?
      end

      def style=(new_style)
        @style = CSL::Style.load new_style
      end

      def process
        raise NotImplementedByEngine
      end

      def append
        raise NotImplementedByEngine
      end

      def bibliography(selector)
        node = style.bibliography
        return unless node

        selection = processor.data.select do |item|
          selector.matches?(item) && !selector.skip?(item)
        end

        sort!(selection, node.sort_keys) unless selection.empty? || !node.sort?

        Bibliography.new(node.bibliography_options) do |bib|
          format.bibliography(bib)

          idx = 1

          selection.each do |item|
            begin
              bib.push item.id, renderer.render(item.cite(idx), node)
            rescue => error
              bib.errors << [item.id.to_s, error]
            ensure
              idx += 1 unless error
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

      def render(mode, data)
        node = case mode
          when :bibliography
            style.bibliography
          when :citation
            style.citation
          else
            raise ArgumentError, "cannot render unknown mode: #{mode.inspect}"
          end

        data.map do |item|
          item.data = processor[item.id].dup
          renderer.render item, node
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
