module CiteProc
  module Ruby
    
    class Renderer
      
      private

      # @param item [CiteProc::CitationItem]
      # @param node [CSL::Style::Names]
      # @return [String]
      def render_names(item, node)
        names = collect_names(item.data)
        
        count_only = self.name.form == 'count'
        
        unless names.empty? || names.map(&:last).flatten.empty?
  
          # handle the editor-translator special case
          if names.map(&:first).sort.join.match(/editortranslator/)
            editors = names.detect { |name| name.first == 'editor' }
            translators = names.detect { |name| name.first == 'translator' }
        
            if editors.last.sort == translators.last.sort
              editors[0] = 'editortranslator'
              names.delete(translators)
            end
          end
      
          names = names.map do |role, names|
            processed = []
            
            truncated = name.truncate(names)

            unless count_only
              processed << name.process_names(role, truncated, processor)
            
              if names.length > truncated.length
                # use delimiter before et al. if there is more than a single name; squeeze whitespace
                others = (et_al.nil? ? localized_terms('et-al', processor).to_s : et_al.process(data, processor))
                link = (name.et_al_use_first.to_i > 1 || name.delimiter_precedes_et_al? ? name.delimiter : ' ')

                processed << [link, others].join.squeeze(' ')
              end
            
              processed.send(prefix_label? ? :unshift : :push, label.process_names(role, names.length, processor)) unless label.nil?
            else
              processed << truncated.length
            end

            processed.join
          end
          
          count_only ? names.inject(0) { |a, b| a.to_i + b.to_i }.to_s : names.join(delimiter)
        else
          count_only ? '0' : substitute.nil? ? '' : substitute.process(data, processor)
        end
      end
      
      
      def parts
        @parts ||= Hash.new { |h, k| k.match(/(non-)?dropping-particle/) ? h['family'] : {} }
      end
  
      def process_names(role, names, processor)

        # set display options
        names = names.each { |name| name.merge_options(attributes) }
        names.first.options['name-as-sort-order'] = 'true' if name_as_sort_order == 'first'

        # name-part formatting
        names.map! do |name|
          name.normalize(name.display_order.map do |token|
            processor.format(name.send(token.tr('-', '_')), parts[token])
          end.compact.join(name.delimiter))
        end        

        # join names
        if names.length > 2
          names = [names[0..-2].join(delimiter), names.last]
        end

        names.join(ampersand(processor))
      rescue Exception => e
        CiteProc.log :error, "failed to process names #{ names.inspect }", e
      end

      def truncate(names)
        # TODO subsequent
        et_al_min? && et_al_min.to_i <= names.length ? names[0, et_al_use_first.to_i] : names
      end

      # @returns the delimiter to be used between the penultimate and last
      # name in the list.
      def ampersand(processor)
        if self.and?
          ampersand = self.and == 'symbol' ? '&' : localized_terms(self.and == 'text' ? 'and' : self.and, processor).to_s(attributes)
          delimiter_precedes_last? ? [delimiter, ampersand, ' '].join : ampersand.center(ampersand.length + 2)
        else
          delimiter
        end
      end
      
      # @returns a list of all name variables covered by this node; each list
      # is wrapped in a list containing the lists role (e.g., 'editor')
      # followed by the list proper.
      def collect_names(item)
        return [] unless self.variable?
        self.variable.split(/\s+/).map { |variable| [variable, (item[variable] || []).map(&:clone)] }.reject { |(_, n)| n.empty? }
      end
      
    end
    
  end
end
