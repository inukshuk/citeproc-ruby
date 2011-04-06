module CiteProc

  module Format

    class Default

      attr_reader :input
      
      Token = Struct.new :content, :annotations, :styles
      AffixFilter = /([\.,\s!?()])/
      
      def initialize
        reset
      end
      
      def name; "CiteProc default style (plain text)"; end
      
      def reset
        @styles = {}
        @tokens = []
        @affixes = [nil, nil]
      end
      
      def input=(input)
        reset
        @tokens = input.split(/(<span[^>]*>[^<]*<\/span>)/).map do |t|
          token = Token.new
          
          if t.match(/^<span(?:\s+class=['"]([\w\s]*)["'])?>([^<]*)<\/span>$/)
            token.content = $2 || ''
            token.annotations = $1.split(/\s+/)
          else
            token = Token.new
            token.content = t
            token.annotations = []
          end
          
          token
        end
      end
      
      def finalize
        [prefix, @tokens.map(&:content).join, suffix].compact.join
      end
      
      def prefix
        return nil if @affixes[0].nil?
        @affixes[0].match(/([\.;:!?\s])$/) && @tokens.first.content.start_with?($1) ? @affixes[0].sub(/\.$/, '') : @affixes[0]
      end

      def suffix
        return nil if @affixes[1].nil?
        @affixes[1].match(/^([\.;:!?\s])/) && @tokens.last.content.end_with?($1) ? @affixes[1].sub(/^\./, '') : @affixes[1]
      end
            
      def set_prefix(prefix)
        @affixes[0] = prefix
      end

      def set_suffix(suffix)
        @affixes[1] = suffix
      end
      
      # @param display 'block', 'left-margin', 'right-inline', 'inline'
      def set_display(display)
        @styles['display'] = display || 'inline'
      end
      
      def set_strip_periods(strip)
        @tokens.each { |token| token.content = token.content.gsub(/\.+/, ' ').squeeze(' ').gsub(/^\s+|\s+$/, '') } if strip == 'true'
      end
            
      # @param style 'normal', 'italic', 'oblique' 
      def set_font_style(style)
        @styles['font-style'] = style || 'normal'
      end
      
      # @param variant 'normal', 'small-caps'
      def set_font_variant(variant)
        @styles['font-variant'] = variant || 'normal'
      end
   
      # @param weight 'normal', 'bold', 'light' 
      def set_font_weight(weight)
        @styles['font-weight'] = weight || 'normal'
      end

      # @param decoration 'none', 'underline'
      def set_text_decoration(decoration)
        @styles['text-decoration'] = decoration || 'none'
      end

      # @param align 'baseline', 'sub', 'sup' 
      def set_vertical_align(align)
        @styles['vertical-align'] = align || 'baseline'
      end

      # @param case 'lowercase', 'uppercase', 'capitalize-first', 'capitalize-all', 'title', 'sentence'
      def set_text_case(text_case)

        # note: the nocase annotations does not override lowercase and uppercase
        
        case text_case
        when 'lowercase'
          @tokens.each { |token| token.content = UnicodeUtils ? UnicodeUtils.downcase(token.content) : token.content.downcase }
          
        when 'uppercase'
          @tokens.each { |token| token.content = UnicodeUtils ? UnicodeUtils.upcase(token.content) : token.content.upcase }
          
        when 'capitalize-first'
          token = @tokens.detect { |token| !token.annotations.include?('nocase') }
          token.content.sub!(/^./) { UnicodeUtils ? UnicodeUtils.upcase($&) : $&.upcase }
          
        when 'capitalize-all'
          # @tokens.each { |token| token.content.gsub!(/\b\w/) { $&.upcase } unless token.annotations.include?('nocase') }
          @tokens.each { |token| token.content = token.content.split(/(\s+)/).map(&:capitalize).join unless token.annotations.include?('nocase') }
          
        # TODO exact specification?
        when 'title'
          @tokens.each { |token| token.content = token.content.split(/(\s+)/).map { |w| w.match(/^(and|of|a|an|the)$/i) ? w : w.gsub(/\b\w/) { UnicodeUtils ? UnicodeUtils.upcase($&) : $&.upcase } }.join.sub(/^(\w)/) {$&.upcase} unless token.annotations.include?('nocase') }

        # TODO exact specification?
        when 'sentence'
          @tokens.each { |token| token.content.capitalize! unless token.annotations.include?('nocase') }

        else
          # nothing
        end
      end

    end
    
  end
end