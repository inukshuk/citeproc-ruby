module CiteProc
  module Ruby

    class Renderer

      # @return [CSL::Locale] the locale including the in-style locale
      #   definitions of the style currently being rendered
      def locale
        localize(base_locale)
      end

      # @param locale [CSL::Locale, String] a locale or an IETF tag;
      #   locales are used as is and never changed by the renderer
      def locale=(locale)
        @locale = locale.is_a?(CSL::Locale) ? locale : CSL::Locale.load(locale)
      end

      def translate(name, options = {})
        locale.translate(name, options)
      end

      # @return [String] number as an ordinal
      def ordinalize(number, options = {})
        locale.ordinalize(number, options)
      end

      private

      def clear_locale_cache!
        @localized, @locales = nil, nil
      end

      # @return [CSL::Locale] the locale without in-style locale
      #   definitions; defaults to the default locale
      def base_locale
        @locale ||= CSL::Locale.load
      end

      # Localized copies are cached per style and locale; the
      # style and the locale themselves are never changed.
      #
      # @param locale [CSL::Locale]
      # @return [CSL::Locale] the locale localized for the current style
      def localize(locale)
        return locale if style.nil?

        @localized ||= {}.compare_by_identity
        localized = (@localized[style] ||= {}.compare_by_identity)
        localized[locale] ||= style.localize(locale)
      end

      # @param language [String] an IETF tag
      # @return [CSL::Locale] the (cached) locale for the language
      def locale_for(language)
        @locales ||= {}
        @locales[language] ||= CSL::Locale.load(language)
      end

    end

  end
end
