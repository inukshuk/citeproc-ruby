# -*- encoding: utf-8 -*-

module CiteProc
  module Ruby

    class Format

      @available = []

      @stopwords = {
        :en => [
          'about', 'above', 'across', 'afore', 'after', 'against', 'along',
          'alongside', 'amid', 'amidst', 'among', 'amongst', 'anenst', 'apropos',
          'apud', 'around', 'as', 'aside', 'astride', 'at', 'athwart', 'atop',
          'barring', 'before', 'behind', 'below', 'beneath', 'beside', 'besides',
          'between', 'beyond', 'but', 'by', 'circa', 'despite', 'd', 'down', 'during',
          'except', 'for', 'forenenst', 'from', 'given', 'in', 'inside', 'into',
          'lest', 'like', 'modulo' 'near', 'next', 'notwithstanding', 'of', 'off',
          'on', 'onto', 'out', 'over', 'per', 'plus', 'pro', 'qua', 'sans', 'since',
          'than', 'through', 'thru', 'throughout', 'thruout', 'till', 'to', 'toward',
          'towards', 'under', 'underneath', 'until', 'unto', 'up', 'upon', 'versus',
          'vs', 'v', 'via', 'vis-à-vis', 'with', 'within', 'without'
        ]
      }

      class << self
        attr_reader :available, :stopwords

        def inherited(base)
          available << base
        end

        def load(name = nil)
          return new unless name

          name = name.to_s.downcase

          klass = available.detect do |format|
            format.name.split('::')[-1].downcase == name
          end

          raise(Error, "unknown format: #{name}") unless klass

          klass.new
        end

        def stopword?(word, locale = :en)
          return unless stopwords.key?(locale)
          stopwords[locale].include?(word.downcase)
        end
      end

      attr_reader :locale

      def keys
        @keys ||= (CSL::Schema.attr(:formatting) - [:prefix, :suffix, :display])
      end

      def apply(input, node, locale = nil)
        return '' if input.nil?
        return input if input.empty? || node.nil?

        # create a dummy node if node is an options hash?

        @input, @output, @node, @locale = input, input.dup, node, locale

        setup!

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
        end unless options.empty?

        output.gsub! /\.+/, '' if node.strip_periods?

        if node.quotes? && !locale.nil?
          output.replace locale.quote(output)
        end

        finalize_content!

        unless node.is_a? CSL::Style::Layout
          apply_prefix if options.key?(:prefix)
          apply_suffix if options.key?(:suffix)
        end

        apply_display if options.key?(:display)

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
          output.sub!(/^([^\p{L}]*)(\p{Ll})/) { "#{$1}#{CiteProc.upcase($2)}" }

        when 'capitalize-all'
          output.gsub!(/\b(\p{Ll})/) { CiteProc.upcase($1) }

        when 'sentence'
          output.sub!(/^([^\p{L}]*)(\p{Ll})/) { "#{$1}#{CiteProc.upcase($2)}" }
          output.gsub!(/\b(\p{Lu})(\p{Lu}+)\b/) { "#{$1}#{CiteProc.downcase($2)}" }

        when 'title'
          # TODO add support for stop words consisting of multiple words
          # TODO localize
          output.gsub!(/\b(\p{Lu})(\p{Lu}+)\b/) { "#{$1}#{CiteProc.downcase($2)}" }

          # TODO exceptions: first, last word; followed by colon
          output.gsub!(/\b(\p{Ll})(\p{L}+)\b/) do |word|
            if Format.stopword?(word)
              word
            else
              "#{CiteProc.upcase($1)}#{$2}"
            end
          end

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
