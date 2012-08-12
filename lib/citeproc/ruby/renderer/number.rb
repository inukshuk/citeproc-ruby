module CiteProc
	module Ruby

		class Renderer

      MAX_ROMAN = 5000

      FACTORS = [
				['m', 1000], ['cm', 900], ['d', 500], ['cd', 400],
      	['c',  100], ['xc',  90], ['l',  50], ['xl',  40],
      	['x',   10], ['ix',   9], ['v',   5], ['iv',   4],
      	['i',    1]
			].freeze


			# @param item [CiteProc::CitationItem]
			# @param node [CSL::Style::Number]
			# @return [String]
			def render_number(item, node)
				raise ArgumentError unless node.has_variable?

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

			# @param number [#to_i] the number to convert
			# @return [String] roman equivalent of the passed-in number
			def romanize(number)
				number, roman = number.to_i, ''

				return number unless number > 0 || number < MAX_ROMAN

				FACTORS.each do |code, factor|
					count, number = number.divmod(factor)
					roman << (code * count)
				end

				roman
			end

			def ordinalize(number, options = {})
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
