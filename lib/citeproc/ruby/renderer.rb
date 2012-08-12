module CiteProc
	module Ruby

		class Renderer

			# @param item [CiteProc::CitationItem]
			# @param node [CSL::Node]
			# @return [String]
			def render(data, node)
				specialize = "render_#{node.nodename}"
				raise ArgumentError unless respond_to?(specialize)

				send specialize, data, node
			end

			def translate(options)
			end
			
		end

	end
end
