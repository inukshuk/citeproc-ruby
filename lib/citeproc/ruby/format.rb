module CiteProc
  module Ruby

    class Format

      @available = []

      class << self
        attr_reader :available

        def inherited(base)
          available << base
        end

        def load(name = nil)
          return new unless name

          name = name.to_s.downcase

          klass = available.detect do |format|
            format.name.downcase == name
          end

          raise(Error, "unknown format: #{name}") if klass.nil?

          klass.new
        end
      end

      def name
        self.class.name
      end

      def keys
        @keys ||= (CSL::Schema.attr(:formatting) - [:prefix, :suffix, :display])
      end

      def apply(input, node)
        return '' if input.nil?
        return input if input.empty? || node.nil?

        @input, @output, @node = input, input.dup, node

        setup!

        unless options.empty?

          # NB: Layout nodes apply formatting to
          # affixes; all other nodes do not!
          if node.is_a? CSL::Style::Layout
            apply_prefix if options.key?(:prefix)
            apply_suffix if options.key?(:suffix)
          end

          keys.each do |format|
            if options.key?(format)
              method = "apply_#{format}".tr('-', '_')
              send method if respond_to?(method)
            end
          end

          output.gsub! /\./, '' if node.strip_periods?

          # TODO quotes needs locale

          finalize_content!

          unless node.is_a? CSL::Style::Layout
            apply_prefix if options.key?(:prefix)
            apply_suffix if options.key?(:suffix)
          end

          apply_display if options.key?(:display)
        end

        finalize!

        output
      ensure
        cleanup!
      end

      def apply_text_case
        case options[:'text-case']
        when 'lowercase'
          output.replace CiteProc.downcase output

        when 'uppercase'
          output.replace CiteProc.upcase output

        when 'capitalize-first'
          output.sub! /^(\p{Ll})/, CiteProc.upcase($1)

        when 'capitalize-all'
          output.gsub! /\b(\p{Ll})/, CiteProc.upcase($1)

        when 'sentence'
          output.gsub! /\b\p{Lu}(\p{Lu}+)\b/, CiteProc.downcase($1)
          output.gsub! /\b(\p{Ll})\p{Ll}*\b/, CiteProc.upcase($1)

        when 'title'
          # TODO needs locale stop words
        end
      end

      def apply_prefix
        output.prepend(options[:prefix])
      end

      def apply_suffix
        output.concat(options[:suffix])
      end

      protected

      attr_reader :input, :output, :node

      def options
        @options ||= @node.formatting_options
      end

      def finalize!
      end

      def finalize_content!
      end

      def setup!
      end

      def cleanup!
        @input, @output, @node, @options = nil
      end
    end

  end
end
