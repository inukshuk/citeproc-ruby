module CiteProc
  module Ruby

    class Renderer

      # The date parts from largest to smallest
      DATE_PARTS = %w{ year month day }.freeze

      # @param item [CiteProc::CitationItem]
      # @param node [CSL::Node]
      # @raise CSL::Error if the locale has no date in the form of the node
      # @return [String]
      def render_date(item, node)
        return '' unless node.has_variable?

        # Observers see the date as rendered:
        # a date without the date parts used counts as empty
        item.data.deferred_read_attribute(node.variable) do |date|
          next '' if date.nil? || date.empty?
          next date.to_s if date.literal?

          parts, delimiter = node.parts_for(locale), node.delimiter_for(locale)

          if date.range?
            render_date_range date, parts, delimiter
          else
            render_date_parts date, parts, delimiter
          end
        end
      end

      # Renders a date range. The date parts which are the same for
      # both dates are rendered only once; the date parts which differ
      # are rendered for both dates and are joined by the range delimiter
      # of the largest date part that differs.
      #
      # @param date [CiteProc::Date] the date range
      # @param parts [Array<CSL::Style::DatePart, CSL::Locale::DatePart>]
      # @param delimiter [String]
      # @return [String]
      def render_date_range(date, parts, delimiter)
        from, to = date.parts

        # Skip date parts without values (e.g., days in a month range)
        parts = parts.select { |part| from[part.name] || to[part.name] }

        # Open ranges are rendered with a trailing range delimiter
        return [
          render_date_parts(from, parts, delimiter),
          range_delimiter_for(parts, 'year')
        ].join('') if date.open_range?

        names = parts.map(&:name)
        largest = DATE_PARTS.detect do |name|
          names.include?(name) && from[name] != to[name]
        end

        return render_date_parts(from, parts, delimiter) if largest.nil?

        # If one date is more precise than the other, all parts differ
        differing = names.any? { |name| from[name].nil? != to[name].nil? } ?
          DATE_PARTS :
          DATE_PARTS.drop_while { |name| name != largest }

        before, range, after = split_date_parts(parts, differing) || [[], parts, []]

        [
          render_date_parts(from, before, delimiter),
          [
            render_date_parts(from, without_suffix(range), delimiter),
            render_date_parts(to, range, delimiter)
          ].join(range_delimiter_for(parts, largest)),
          render_date_parts(from, after, delimiter)
        ].reject(&:empty?).join(delimiter)
      end

      def render_date_parts(date, parts, delimiter)
        parts.map { |part|
          render date, part
        }.reject(&:empty?).join(delimiter)
      end

      # @param date [CiteProc::Date, CiteProc::Date::DateParts]
      # @param node [CSL::Style::DatePart, CSL::Locale::DatePart]
      # @return [String]
      def render_date_part(date, node)
        case
        when node.day?
          case
          when date.day.nil?
            ''
          when node.form == 'ordinal'
            if date.day > 1 && locale.limit_day_ordinals?
              date.day.to_s
            else
              # The ordinal uses the gender of the month
              ordinalize date.day, :noun => date.month && 'month-%02d' % date.month
            end
          when node.form == 'numeric-leading-zeros'
            '%02d' % date.day
          else
            date.day.to_s
          end

        when node.month?
          case
          when date.season.is_a?(String)
            date.season
          when date.season?
            translate(('season-%02d' % date.season), node.attributes_for(:form))
          when date.month.nil?
            ''
          when node.numeric?
            date.month.to_s
          when node.numeric_leading_zeros?
            '%02d' % date.month
          else
            translate(('month-%02d' % date.month), node.attributes_for(:form))
          end

        when node.year?
          year = date.year
          year = year % 100 if node.short?

          if date.ad?
            year = year.to_s
            year << translate(:ad) if date.ad?
          elsif date.bc?
            year = (-1*year).to_s
            year << translate(:bc) if date.bc?
          else
            year = year.to_s
          end

          year

        else
          ''
        end
      end

      private

      # @return [String] the range delimiter set on the date part
      #   with the given name; defaults to an en-dash
      def range_delimiter_for(parts, name)
        part = parts.detect { |p| p.name == name }
        part && part[:'range-delimiter'] || '–'
      end

      # Splits the date parts into the common parts before, the
      # differing parts, and the common parts after them.
      #
      # @return [Array<Array>, nil] the split parts or nil if the
      #   differing parts are not adjacent
      def split_date_parts(parts, differing)
        first = parts.index { |part| differing.include?(part.name) }
        last = parts.rindex { |part| differing.include?(part.name) }
        range = parts[first..last]

        return unless range.all? { |part| differing.include?(part.name) }

        [parts[0...first], range, parts[(last + 1)..]]
      end

      # @return [Array<CSL::Node>] the date parts with a copy
      #   of the last date part without its suffix
      def without_suffix(parts)
        last = parts[-1]
        return parts unless last.attribute?(:suffix)

        copy = last.deep_copy
        copy[:suffix] = nil

        [*parts[0...-1], copy]
      end

    end

  end
end
