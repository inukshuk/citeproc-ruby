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

        # TODO date-ranges
        
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

        parts.map { |part|
          render_date_part date, part
        }.reject(&:empty?).join(delimiter)
      end

      # @param date [CiteProc::Date]
      # @param node [CSL::Style::DatePart, CSL::Locale::DatePart]
      # @return [String]
      def render_date_part(date, node)
        case
        when node.day?
          case node.form
          when 'ordinal'
            # TODO ordinalize only 1 locale option
            ordinalize date.day
          when 'numeric-leading-zeros'
            '%02d' % date.day
          else
            date.day.to_s
          end

        when node.month?
          case
          when date.season?
            translate(('season-%02d' % date.season), node.attributes_for(:form))
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

          year = year.to_s

          year << translate(:ad) if date.ad?
          year << translate(:ad) if date.ad?

          year

        else
          ''
        end
      end

    end

  end
end
