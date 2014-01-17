# -*- encoding: utf-8 -*-

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

      # Applies the current format on the string using the
      # node's formatting options.
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

      # Concatenates two strings, making sure that squeezable
      # characters are not duplicated between string and suffix.
      #
      # @param [String] string
      # @param [String] suffix
      #
      # @return [String] new string consisting of string
      #   and suffix
      def concat(string, suffix)
        return "#{string}#{suffix}" unless @format
        @format.concat(string, suffix)
      end

      def locale=(locale)
        @locale = CSL::Locale.load(locale)
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
        dash = translate('page-range-delimiter') || '–' # en-dash

        pages.gsub PAGE_RANGE_PATTERN do
          affixes, f, t = [$1, $3, $4, $6], $2, $5

          if affixes.all?(&:empty?)

            d = f.length - t.length

            if d >= 0
              t.prepend f[0, d] unless d.zero?

              case format
              when 'chicago'

              when 'expanded'
                # nothing to do

              when 'minimal'
                t = t.each_char.drop_while.with_index { |c, i| c == f[i] }.join('')

              when 'minimal-two'
                len = t.length

                if len > 2
                  t = t.each_char.drop_while.with_index { |c, i|
                    c == f[i] && len - i > 2
                  }.join('')
                end

              else
                raise ArgumentError, "unknown page range format: #{format}"
              end
            end
          end

          affixes.zip([f, dash, t]).flatten.compact.join('')
        end
      end

      PAGE_RANGE_PATTERN =
        #   ------------  -2-  ------------             ------------  -5-  ------------
        /\b([[:alpha:]]*)(\d+)([[:alpha:]]*)\s*[–-]+\s*([[:alpha:]]*)(\d+)([[:alpha:]]*)\b/

    end

  end
end
