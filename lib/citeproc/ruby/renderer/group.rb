module CiteProc
  module Ruby
    
    class Renderer
      
      private

      # @param item [CiteProc::CitationItem]
      # @param node [CSL::Style::Group]
      # @return [String]
      def render_group(item, node)
        start_observing(item.data)

				if delimiter.nil? || children.length < 2
					processed = children.map { |c| c.process(data, processor) }.reject(&:empty?).join('')
				else
	        processed = children.reduce('') do |ps, child|
		 				p = child.process(data, processor)

						unless p.empty?
							if delimiter && !ps.empty?
								ps.chop! if ps[-1] =~ /[\s\.,:!\?]/ && ps[-1] == delimiter[0]
								
								ps << delimiter
								
								ps.chop! if ps[-1] =~ /[\s\.,:!\?]/ && ps[-1] == p[0]
							end
						
							ps << p
						end
						
						ps
					end
				end

        stop_observing(item.data)

        # if any variable returned nil, skip the entire group
        skip? ? '' : processor.format(processed, attributes)
        
      end
      
      
      def start_observing(item)
        @variables = []
        item.add_observer(self)
      end
      
      def stop_observing(item)
        item.delete_observer(self)
      end
      
      def update(key, value)
        @variables << [key, value]
      end

      def skip?
        @variables && @variables.map(&:last).all?(&:nil?)
      end
      
    end
    
  end
end
