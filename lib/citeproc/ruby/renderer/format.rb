# -*- encoding: utf-8 -*-

module CiteProc
  module Ruby

    class Renderer

      def format
       @format ||= Format.load
      end

      def format=(format)
        @format = Format.load(format)
      end

      # Applies the current format on the string using the
      # node's formatting options.
      def format!(string, node)
        format.apply(string, node, locale, state.language)
      end

      # Reads the item's language without notifying observers.
      #
      # @param item [CiteProc::Item, nil]
      # @return [String, nil] the item's language
      def language_of(item)
        return unless item.respond_to?(:unobservable_read_attribute)
        item.unobservable_read_attribute(:language).to_s
      end

      def join(list, delimiter = nil)
        format.join(list, delimiter)
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
        format.concat(string, suffix)
      end


      # @return [String] the roman numeral of number
			def romanize(number)
				CiteProc::Number.romanize(number)
			end


      # Formats pages according to format. Valid formats are:
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

      # @return [String] the localized range delimiter; defaults to an en-dash
      def range_delimiter
        translate('page-range-delimiter') || '–'
      end

      def format_page_range!(pages, format)
        return if pages.nil?
        return pages if pages.empty?

        dash = range_delimiter

        pages.gsub! PAGE_RANGE_PATTERN do
          from, to = $1, $2
          format_page_bounds(from, to, format, dash) || "#{from}-#{to}"
        end

        # Escaped hyphens are not range delimiters
        pages.gsub!('\\-', '-')
        pages
      end

      PAGE_RANGE_PATTERN = /([[:alnum:]]+)\s*[–-]+\s*([[:alnum:]]+)/

      # A page number with optional prefix and suffix
      PAGE_PATTERN = /\A(\d*[[:alpha:]]+)?(\d+)([[:alpha:]]*)\z/

      ROMAN_PATTERN = /\A[ivxlcdm]+\z/i

      private

      # @return [String, nil] the formatted page range or nil if
      #   the bounds do not form a page range
      def format_page_bounds(from, to, format, dash)
        if ROMAN_PATTERN.match?(from) && ROMAN_PATTERN.match?(to)
          return "#{from}#{dash}#{to}"
        end

        f, t = PAGE_PATTERN.match(from), PAGE_PATTERN.match(to)

        # Ranges must have the same prefix on both sides
        return unless f && t && f[1] == t[1]

        # When there are suffixes or no format was
        # specified we only replace the delimiter
        if format.nil? || !f[3].empty? || !t[3].empty?
          return "#{from}#{dash}#{to}"
        end

        prefix = f[1]
        last = format_page_number(f[2], t[2].dup, format)

        # The prefix is repeated only for expanded ranges
        "#{prefix}#{f[2]}#{dash}#{prefix if format == 'expanded'}#{last}"
      end

      def format_page_number(f, t, format)
        dim = f.length
        delta = dim - t.length

        if delta >= 0
          t.prepend f[0, delta] unless delta.zero?

          format = 'chicago-15' if format == 'chicago'

          if format == 'chicago-15' || format == 'chicago-16'
            # Only the 15th edition expands four digit
            # numbers when three or more digits change
            changes = dim - f.chars.zip(t.chars).
              take_while { |a,b| a == b }.length if dim == 4

            format = case
              when dim < 3
                'expanded'
              when dim == 4 && format == 'chicago-15' && changes > 2
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

        t
      end

    end

  end
end
