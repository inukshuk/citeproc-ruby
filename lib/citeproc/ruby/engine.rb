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
        node = style.bibliography
        return unless node

        selection = processor.data.select do |item|
          selector.matches?(item) && !selector.skip?(item)
        end

        sort!(selection, node.sort_keys) if node.sort?

        CiteProc::Bibliography.new(node.bibliography_options) do |b|
          selection.each do |item|
            begin
              b << renderer.render(item.cite, node)
            rescue => e
              b.errors << [item.id.to_s, e]
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
          item.data = processor[item.id]
          renderer.render item, node
        end
      end


      def update!
        renderer.format = processor.options[:format]
        renderer.locale = processor.options[:locale]

        @style = CSL::Style.load processor.options[:style]
      end

      def sort!(items, keys)
        return itmes.sort! unless !keys.nil? && !keys.empty?

        items.sort! do |a, b|
          compare_items_by_keys(a, b, keys)
        end
      end

      # @returns [-1, 0, 1, nil]
      def compare_items_by_keys(a, b, keys)
        result = 0

        keys.each do |key|
          result = compare_items_by_key(a, b, key)
          return result unless result.zero?
        end

        result
      end

      # @returns [-1, 0, 1, nil]
      def compare_items_by_key(a, b, key)
        if key.macro?
          result = renderer.render_sort(a, b, key.macro, key).reduce &:<=>

        else
          va, vb = a[key.variable], b[key.variable]

          return 0 if va == vb

          # Return early if one side is nil. In this
          # case ascending/descending is irrelevant!
          return  1 if va.nil? || va.empty?
          return -1 if vb.nil? || va.empty?

          result = case CiteProc::Variable.types[key.variable]
            when :names
              node = CSL::Style::Name.new(key.name_options)
              node.all_names_as_sort_order!

              renderer.render_sort(va, vb, node, key).reduce &:<=>

            when :date
              va <=> vb
            when :number
              va <=> vb
            else
              va <=> vb
            end
        end

        result = -result unless key.ascending?
        result
      end
    end
  end
end
