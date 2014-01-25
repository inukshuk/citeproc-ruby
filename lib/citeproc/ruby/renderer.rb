# -*- encoding: utf-8 -*-

module CiteProc
  module Ruby

    class Renderer

      def initialize(options = nil)
        @history = History.new(self, 5)

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
      # @param remember [Boolean] whether or not to remember
      #   the results for this item
      # @return [String] the rendered and formatted string
      def render(item, node, remember = false)
        raise ArgumentError, "no CSL node: #{node.inspect}" unless
          node.respond_to?(:nodename)

        begin
          specialize = "render_#{node.nodename.tr('-', '_')}"

          raise ArgumentError, "#{specialize} not implemented" unless
            respond_to?(specialize, true)

          result = format send(specialize, item, node), node

        rescue => error
          throw error
        ensure
          history.remember! node.nodename, item, result, error if remember
        end
      end

      def render_citation(item, node)
        citation_mode!

        # TODO add item.prefix/suffix before (or after?) formatting
        # TODO author_only

        item.suppress! 'author' if item.suppress_author?

        render item, node.layout
      ensure
        clear_mode!
      end

      def render_bibliography(item, node)
        bibliography_mode!

        # TODO load item-specific locale
        render item, node.layout
      ensure
        clear_mode!
      end

      def render_sort(a, b, node, key)
        sort_mode!(key)

        original_format = @format
        @format = Formats::Text.new

        if a.is_a?(CiteProc::Names)
          [render_name(a, node), render_name(b, node)]
        else
          [render(a.cite, node), render(b.cite, node)]
        end

      ensure
        @format = original_format

        clear_sort_key!
        clear_mode!
      end

      # Applies the current format on the string using the
      # node's formatting options.
      def format(string, node)
        fmt.apply(string, node, locale)
      end

      def format=(format)
        @format = Format.load(format)
      end

      def join(list, delimiter = nil)
        fmt.join(list, delimiter)
      end

      # Concatenates two strings, making sure that squeezable
      # characters are not duplicated between string and suffix.
      #
      # @param [String] string
      # @param [String] suffix
      #
      # @return [String] new string consisting of string
      #   and suffix
      def concat(string, suffix)
        fmt.concat(string, suffix)
      end

      def locale=(locale)
        @locale = CSL::Locale.load(locale)
      end

      def citation_mode!
        @mode == :citation
      end

      def citation_mode?
        @mode == :citation
      end

      def bibliography_mode!
        @mode = :bibliography
      end

      def bibliography_mode?
        @mode == :bibliography
      end

      def sort_mode!(key = nil)
        @mode, @sort_key = :sort, key
      end

      def sort_mode?
        @mode == :sort
      end

      def clear_mode!
        @mode = nil
        self
      end

      def clear_sort_key!
        @sort_key = nil
        self
      end

      def translate(name, options = {})
        locale.translate(name, options)
      end

      # @return [String] number as an ordinal
      def ordinalize(number, options = {})
        locale.ordinalize(number, options)
      end

      # @return [String] the roman numeral of number
			def romanize(number)
				CiteProc::Number.romanize(number)
			end


      # Formats pages accoring to format. Valid formats are:
      #
      # * "chicago": page ranges are abbreviated according to
      #   the Chicago Manual of Style rules.
      # * "expanded": Abbreviated page ranges are expanded to
      #   their non-abbreviated form: 42-45, 321-328, 2787-2816.
      # * "minimal": All digits repeated in the second number
      #   are left out: 42-45, 321-8, 2787-816.
      #
      # @param [String] pages to be formatted
      # @param [String] format to use for formatting
      def format_page_range(pages, format)
        return if pages.nil?
        format_page_range!(pages.dup, format)
      end

      def format_page_range!(pages, format)
        return if pages.nil?

        dash = translate('page-range-delimiter') || '–' # en-dash

        pages.gsub! PAGE_RANGE_PATTERN do
          affixes, f, t = [$1, $3, $4, $6], $2, $5

          # When there are affixes or no format was
          # specified we skip this part. As a result,
          # only the delimiter will be replaced!

          if affixes.all?(&:empty?) && !format.nil?

            dim = f.length
            delta = dim - t.length

            if delta >= 0
              t.prepend f[0, delta] unless delta.zero?

              if format == 'chicago'
                changes = dim - f.chars.zip(t.chars).
                  take_while { |a,b| a == b }.length if dim == 4

                format = case
                  when dim < 3
                    'expanded'
                  when dim == 4 && changes > 2
                    'expanded'
                  when f[-2, 2] == '00'
                    'expanded'
                  when f[-2] == '0'
                    'minimal'
                  else
                    'minimal-two'
                  end
              end

              case format
              when 'expanded'
                # nothing to do
              when 'minimal'
                t = t.each_char.drop_while.with_index { |c, i| c == f[i] }.join('')
              when 'minimal-two'
                if dim > 2
                  t = t.each_char.drop_while.with_index { |c, i|
                    c == f[i] && dim - i > 2
                  }.join('')
                end
              else
                raise ArgumentError, "unknown page range format: #{format}"
              end
            end
          end

          affixes.zip([f, dash, t]).flatten.compact.join('')
        end

        pages
      end

      PAGE_RANGE_PATTERN =
        #   ------------  -2-  ------------             ------------  -5-  ------------
        /\b([[:alpha:]]*)(\d+)([[:alpha:]]*)\s*[–-]+\s*([[:alpha:]]*)(\d+)([[:alpha:]]*)\b/


      protected

      attr_reader :mode, :sort_key, :history

      def fmt
       @format ||= Format.load
      end

    end

  end
end
