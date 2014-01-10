module CiteProc
  module Ruby
    module Formats

      class Html < Format

        @defaults = {
          :css_only  => false,
          :italic    => 'i',      # em
          :bold      => 'b',      # strong
          :container => 'span',   # inner container
          :display   => 'div'     # display container
        }

        class << self
          attr_reader :defaults
        end

        attr_reader :config

        def initialize(config = nil)
          @config = Html.defaults.merge(config)
        end

        def css_only?
          config[:css_only]
        end

        def apply_font_style
          if options[:'font-style'] == 'italic' && !css_only?
            output.replace content_tag(config[:italic], output)
          else
            css[:'font-style'] = options[:'font-style']
          end
        end

        def apply_font_variant
          css['font-variant'] = options[:'font-variant']
        end

        def apply_font_weight
          if options[:'font-weight'] == 'bold' && !css_only?
            output.replace content_tag(config[:bold], output)
          else
            css[:'font-weight'] = options[:'font-weight']
          end
        end

        def apply_text_decoration
          css[:'text-decoration'] = options[:'text-decoration']
        end

        def apply_vertical_align
          css[:'vertical-align'] = options[:'vertical-align']
        end

        def apply_display
          output.replace(
            content_tag(config[:display], output, :display => options[:display])
          )
        end

        protected

        def css
          @css ||= {}
        end

        def finalize_content!
          super
          output.replace content_tag(config[:container], output, css) if @css
        end

        def cleanup!
          @css = nil
          super
        end

        private

        def content_tag(name, content, options = nil)
          "<#{name}#{style(options)}>#{content}</#{name}>"
        end

        def style(options)
          return unless options && !options.empty?
          " style=#{options.map { |*kv| kv.join(': ') }.join('; ').inspect}"
        end

      end

    end
  end
end
