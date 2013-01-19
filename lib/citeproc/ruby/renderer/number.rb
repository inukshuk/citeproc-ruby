module CiteProc
  module Ruby

    class Renderer

      # @param item [CiteProc::CitationItem]
      # @param node [CSL::Style::Number]
      # @return [String]
      def render_number(item, node)
        return '' unless node.has_variable?

        variable = item.data[node.variable]
        return variable.to_s unless variable && variable.numeric?

        numbers = extract_numbers_from variable

        case
        when node.ordinal? || node.long_ordinal?
          options = node.attributes_for :form
          # TODO lookup term of variable to check gender

          numbers.map { |num|
            num =~ /^\d+$/ ? ordinalize(num, options) : num
          }.join('')

        when node.roman?
          numbers.map { |num|
            num =~ /^\d+$/ ? romanize(num) : num
          }.join('')

        else
          numbers.join('')
        end
      end


      # @return [Array<String>]
      def extract_numbers_from(variable)
        numbers = variable.to_s.dup

        numbers.gsub!(/\s*,\s*/, ', ')
        numbers.gsub!(/\s*-\s*/, '-')
        numbers.gsub!(/\s*&\s*/, ' & ')

        numbers.split(/(\s*[,&-]\s*)/)
      end

    end

  end
end
