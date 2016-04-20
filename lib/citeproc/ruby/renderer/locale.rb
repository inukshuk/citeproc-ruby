module CiteProc
  module Ruby

    class Renderer

      def locale
        @locale ||= CSL::Locale.load
      end

      def locale=(locale)
        @locale = CSL::Locale.load(locale)
      end

      def translate(name, options = {})
        locale.translate(name, options)
      end

      # @return [String] number as an ordinal
      def ordinalize(number, options = {})
        locale.ordinalize(number, options)
      end

      def merge_locale_with_style_locale!(node)
        return unless node
        unless @merged_locales
          @merged_locales = {}
          @merged_locales.compare_by_identity
        end

        style = node.root
        return unless style.respond_to?(:locales)

        return if @merged_locales[@locale] && @merged_locales[@locale].include?(style)

        matching_locale_in_style = style.locales.detect { |l| l == @locale }
        if matching_locale_in_style
          @locale = matching_locale_in_style.merge(@locale)
          @merged_locales[@locale] ||= []
          @merged_locales[@locale] << style
        end
      end

    end

  end
end
