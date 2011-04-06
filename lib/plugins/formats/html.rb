module CiteProc
  module Format
    class Html < Default

      def initialize
        super
        @container = :span
        @mode = :individual
      end

      def name; "CiteProc HTML style"; end

      def self.filter(string)
        string.gsub(/&([^#])/i, '&#38;\1')
      end

    
      def finalize
        content = @tokens.map(&:content).join

        unless @styles.empty?
          content = @mode == :combined ? content_tag(@container, content, @styles) : individual_tags(content)
        end

        [prefix, content, suffix].reject(&:nil?).join      
      end

      def input=(input)
        super
        @tokens.each { |token| token.content = Html.filter(token.content) }
      end

      # @param display 'block', 'left-margin', 'right-inline', 'inline'
      def set_display(display)
        super
        @container = :div if !display.nil? && display != 'inline'
      end


      protected

      def individual_tags(content)
        @styles.each_pair do |style, value|
          case
          when style == 'font-weight' && value == 'bold'
            content = content_tag(:b, content)
          when style == 'font-style' && value == 'italic'
            content = content_tag(:i, content)
          else
            content = content_tag(:span, content, style => value)
          end
        end
      
        content
      end
    
      def content_tag(name, content, styles=nil)
        if styles.nil?
          %Q{<#{name}>#{content}</#{name}>}
        else
          %Q{<#{name} style="#{ styles.map { |k,v| [k,v].join(': ') }.join('; ') }">#{content}</#{name}>}
        end
      end
    end
    
  end
end