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


      # @param pages [String] the pages to format
      # @param format [String, nil] the page range format
      # @return [String, nil] the pages formatted according to format
      #   using the localized range delimiter
      def format_page_range(pages, format)
        CiteProc::Number.format_page_range(pages, format, range_delimiter)
      end

      # @return [String] the localized range delimiter; defaults to an en-dash
      def range_delimiter
        translate('page-range-delimiter') || '–'
      end

    end

  end
end
