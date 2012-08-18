module CiteProc
  module Ruby

    class Renderer

      private

      # @param item [CiteProc::CitationItem]
      # @param node [CSL::Node]
      # @return [String]
      def render_date(item, node)
        return '' unless node.has_variable?

        date = item.data[node.variable]

        case
        when date.nil?
          ''
        when date.literal?
          date.literal
        when date.range?
          render_date_range(date, node)
        else
          node.map { |part| part.process(date, processor) }.join(node.delimiter)
        end
      end

      def render_date_range(date, node)
        order = parts(processor)

        parts = [order, order].zip(date.display_parts).map do |order, parts|
          order.map { |part| parts.include?(part['name']) ? part : nil }.compact
        end

        result = parts.zip([date, date.to]).map { |parts, date| parts.map { |part| part.process(date, processor) }.join(delimiter) }.compact
        result[0].gsub!(/\s+$/, '')
        result.join(parts[0].last.range_delimiter)
      end

      def date_parts(processor)
        has_form? ? merge_parts(localized_date_parts(form, processor), children) : children
      end


      # Combines two lists of date-part elements; includes only the parts set
      # in the 'date-parts' attribute and retains the order of elements in the
      # first list.
      def merge_parts(p1, p2)
        merged = p1.map do |part|
          DatePart.new(part.attributes, style).merge(p2.detect { |p| p['name'] == part['name'] })
        end
        merged.reject { |part| !date_parts.match(Regexp.new(part['name'])) }
      end

      def date_parts
        self['date-parts'] || 'year-month-day'
      end

    end

  end
end
