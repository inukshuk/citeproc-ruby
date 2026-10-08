module CiteProc
  module Ruby
    module Formats

      class Html < Format

        @defaults = {
          :css_only  => false,
          :italic    => 'i',      # em
          :bold      => 'b',      # strong
          :container => 'span',   # inner container
          :display   => 'div',    # display container

          :bib_container       => 'ol',
          :bib_container_class => 'csl-bibliography',
          :bib_entry           => 'li',
          :bib_entry_class     => 'csl-entry',
          :bib_hanging_indent  => '0.5',
          :bib_unit            => 'em',
          :bib_indent          => '  '
        }

        @vertical_align = Hash.new { |_,k| k }
        @vertical_align['sup'] = 'super'

        class << self
          attr_reader :defaults
          attr_reader :vertical_align
        end

        attr_reader :config

        def initialize(config = nil)
          if config.nil?
            @config = Html.defaults.dup
          else
            @config = Html.defaults.merge(config)
          end

          @css = nil
        end

        def bibliography(bibliography)
          ol, li, indent, unit =
            config.values_at(:bib_container, :bib_entry, :bib_indent, :bib_unit)

          container_options = {}
          container_options['class'] = config[:bib_container_class]

          entry_options = {}
          entry_options['class'] = config[:bib_entry_class]

          entry_options['style'] = {}
          container_options['style'] = {}

          if bibliography.line_spacing != 1.0
            container_options['style']['line-height'] = bibliography.line_spacing
          end

          if bibliography.hanging_indent?
            hanging_indent = "#{config[:bib_hanging_indent]}#{unit}"

            container_options['style']['padding-left'] = hanging_indent
            entry_options['style']['text-indent'] = "-#{hanging_indent}"
          end

          if bibliography.entry_spacing != 1.0
            entry_options['style']['margin-bottom'] = "#{bibliography.entry_spacing}#{unit}"
          end

          bibliography.header = opening_tag(ol, container_options)
          bibliography.footer = closing_tag(ol)

          bibliography.prefix = [indent, opening_tag(li, entry_options)].join('')
          bibliography.suffix = closing_tag(li)

          bibliography.connector = indent ? "\n" : ''
          bibliography
        end

        def css_only?
          config[:css_only]
        end

        def apply_font_style
          if options[:'font-style'] == 'italic' && !css_only?
            output.replace content_tag(config[:italic], output)
          else
            css['font-style'] = options[:'font-style']
          end
        end

        def apply_font_variant
          css['font-variant'] = options[:'font-variant']
        end

        def apply_font_weight
          if options[:'font-weight'] == 'bold' && !css_only?
            output.replace content_tag(config[:bold], output)
          else
            css['font-weight'] = options[:'font-weight']
          end
        end

        def apply_text_decoration
          css['text-decoration'] = options[:'text-decoration']
        end

        def apply_vertical_align
          css['vertical-align'] = Html.vertical_align[
            options[:'vertical-align']
          ]
        end

        def apply_display
          output.replace(
            content_tag(config[:display], output, 'class' => "csl-#{options[:display]}" )
          )
        end

        # The suffix of a layout goes into a trailing display block
        def apply_suffix
          close = closing_tag(config[:display])
          return super unless node.is_a?(CSL::Style::Layout) && output.end_with?(close)

          output.replace "#{squeeze_suffix(output.delete_suffix(close), suffix)}#{close}"
        end

        def prefix
          CSL.encode_xml_text(options[:prefix])
        end

        def suffix
          CSL.encode_xml_text(options[:suffix])
        end

        def escape_quotes?
          true
        end

        def strip(string)
          string.split(/((?:\A<\p{Alpha}[^>]*>)|(?:<\/\p{Alpha}[^>]*>))\z/, 2)
        end

        protected

        def css
          @css ||= {}
        end

        def finalize_content!
          super
          output.replace content_tag(config[:container], output, 'style' => css) if @css
        end

        def finalize!
          # TODO find a better solution for this (strip tags?)
          # For now make sure not to double encode entities
          # by matching spaces before or after.

          output.gsub!(/[&<]\s/, '& ' => '&amp; ', '< ' => '&lt; ')
          output.gsub!(/\s>/, ' &gt;')
        end

        def cleanup!
          @css = nil
          super
        end

        private

        def content_tag(name, content, options = nil)
          "#{opening_tag(name, options)}#{content}#{closing_tag(name)}"
        end

        def style_for(options)
          return unless options && !options.empty?
          options.map { |*kv| kv.join(': ') }.join('; ')
        end

        def attribute_assignments(options)
          return unless options

          options = options.select { |_, v| !v.nil? }

          return unless !options.empty?

          " #{options.map { |k, v| [k, v.inspect].join('=') }.join(' ')}"
        end

        def opening_tag(name, options = nil)
          if options && options.key?('style')
            options['style'] = style_for(options['style'])
          end

          "<#{name}#{attribute_assignments(options)}>"
        end

        def closing_tag(name)
          "</#{name}>"
        end
      end

      class CiteProcJS < Html
        # The superscript characters converted to sup tags by citeproc-js
        SUPERSCRIPTS = /[ª²-³¹-ºʰ-ʸˀ-ˁˠ-ˤۥ-ۦᴬ-ᴮᴰ-ᴺᴼ-ᵍᵏ-ᵡ⁰-ⁱ⁴-ⁿ℠™㆒-㆟]/

        def initialize
          super(
            :bib_container => 'div',
            :bib_container_class => 'csl-bib-body',
            :bib_entry => 'div',
            :bib_entry_class => 'csl-entry'
          )
        end

        def bibliography(bibliography)
          ol, li, indent =
            config.values_at(:bib_container, :bib_entry, :bib_indent)

          container_options = {}
          container_options['class'] = config[:bib_container_class]

          entry_options = {}
          entry_options['class'] = config[:bib_entry_class]

          bibliography.header = opening_tag(ol, container_options)
          bibliography.footer = closing_tag(ol)

          bibliography.prefix = [indent, opening_tag(li, entry_options)].join('')
          bibliography.suffix = closing_tag(li)

          bibliography.connector = indent ? "\n" : ''
          bibliography
        end

        def apply_vertical_align
          case options[:'vertical-align']
          when 'sup', 'sub'
            output.replace content_tag(options[:'vertical-align'], output)
          else
            super
          end
        end

        protected

        def finalize!
          super

          # Use typographic apostrophes
          output.gsub!(/(?<=\p{L})'|'(?=\d)/, '’')

          output.gsub!(SUPERSCRIPTS) do |char|
            content_tag('sup', char.unicode_normalize(:nfkc))
          end
        end

        private

        def style_for(options)
          return unless options && !options.empty?
          options.map { |k, v| "#{k}:#{v};" }.join
        end
      end

    end
  end
end
