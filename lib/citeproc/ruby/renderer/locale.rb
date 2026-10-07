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

      # @return [Hash<String,String>] the abbreviations of locator labels
      #   including the localized short terms
      def locator_abbreviations
        @locator_abbreviations ||= {}.compare_by_identity
        @locator_abbreviations[locale] ||= begin
          terms = {}

          CiteProc::CitationItem.labels.each do |label|
            [false, true].each do |plural|
              term = translate(label, :form => 'short', :plural => plural)
              terms[term] = label.to_s unless term.to_s.empty?
            end
          end

          CiteProc::CitationItem.locator_abbreviations.merge(terms)
        end
      end

      private

      def clear_locale_cache!
        @localized, @locales, @locator_abbreviations = nil, nil, nil
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
