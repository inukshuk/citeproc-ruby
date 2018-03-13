module CiteProc
  module Ruby

    class Renderer

      # @param item [CiteProc::CitationItem]
      # @param node [CSL::Node]
      # @raise RenderingError
      # @return [String]
      def render_date(item, node)
        return '' unless node.has_variable?

        date = item.data[node.variable]
        return '' if date.nil? || date.empty?

        return date.to_s if date.literal?

        if node.localized?
          localized_node = locale.date.detect { |d| d.form == node.form } or
            raise RenderingError, "no localized date for form #{node.form} found"

          delimiter, filter = node.delimiter, node.parts_filter

          parts = localized_node.parts.select do |part|
            filter.include? part.name
          end
        else
          parts, delimiter = node.parts, node.delimiter
        end

        if date.range?
          render_date_range date, node, parts, delimiter
        else
          parts.map { |part|
            render date, part
          }.reject(&:empty?).join(delimiter)
        end
      end

      def render_date_range(date, node, parts, delimiter)
        delimit_range_at = 'day' # TODO date.delimit_range_at

        from_parts = parts.reverse.drop_while { |part|
          part.name != delimit_range_at
        }.reverse

        unless from_parts.empty?
          from = from_parts.map { |part|
            format! render_date_part(date, part, part: 0), part
          }.reject(&:empty?).join(delimiter)

          suffix, range_delimiter = from_parts[-1].values_at(:suffix, :'range-delimiter')

          unless suffix.nil?
            from = from[0, from.length - suffix.length]
          end
        end

        to = parts.map { |part|
          format! render_date_part(date, part, part: 1), part
        }.reject(&:empty?).join(delimiter)

        [from, to].join(range_delimiter || '–')
      end


      # @param date [CiteProc::Date]
      # @param node [CSL::Style::DatePart, CSL::Locale::DatePart]
      # @return [String]
      def render_date_part(date, node, part: 0)
        d = date.parts[part]
        return '' if d.nil? || d.empty?

        case
        when node.day?
          case
          when d.day.nil?
            ''
          when node.form == 'ordinal'
            if d.day > 1 && locale.limit_day_ordinals?
              d.day.to_s
            else
              ordinalize d.day
            end
          when node.form == 'numeric-leading-zeros'
            '%02d' % d.day
          else
            d.day.to_s
          end

        when node.month?
          case
          # TODO support seasons in date parts!
          when date.season?
            translate(('season-%02d' % date.season), node.attributes_for(:form))
          when d.month.nil?
            ''
          when node.numeric?
            d.month.to_s
          when node.numeric_leading_zeros?
            '%02d' % d.month
          else
            translate(('month-%02d' % d.month), node.attributes_for(:form))
          end

        when node.year?
          year = d.year
          year = year % 100 if node.short?

          if d.ad?
            year = year.to_s
            year << translate(:ad) if d.ad?
          elsif d.bc?
            year = (-1*year).to_s
            year << translate(:bc) if d.bc?
          else
            year = year.to_s
          end

          year

        else
          ''
        end
      end

    end
  end
end
