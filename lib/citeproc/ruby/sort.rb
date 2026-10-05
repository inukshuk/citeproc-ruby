begin
  require 'ffi-icu'
rescue LoadError
  # ignore
end

module CiteProc
  module Ruby

    module SortItems

      def sort!(items, keys)
        return items unless !keys.nil? && !keys.empty?

        # TODO refactor
        if items.is_a?(CitationData)
          items.sort! do |a, b|
            compare_items_by_keys(a.data, b.data, keys)
          end
        else
          items.sort! do |a, b|
            compare_items_by_keys(a, b, keys)
          end
        end
      end

      # @returns [-1, 0, 1, nil]
      def compare_items_by_keys(a, b, keys)
        result = 0

        keys.each do |key|
          result = compare_items_by_key(a, b, key)
          return result unless result.zero?
        end

        result
      end

      # @returns [-1, 0, 1, nil]
      def compare_items_by_key(a, b, key)
        if key.macro?
          result = compare_items(*renderer.render_sort(a, b, key.macro, key))

        else
          va, vb = a[key.variable], b[key.variable]

          # Return early if one side is nil.
          # In this case ascending/descending is irrelevant!
          if va.nil? || va.empty?
            return vb.nil? || vb.empty? ? 0 : 1
          elsif vb.nil? || vb.empty?
            return -1
          end

          result = case CiteProc::Variable.types[key.variable]
            when :names
              node = CSL::Style::Name.new(key.name_options)
              node.all_names_as_sort_order!

              compare_items(*renderer.render_sort(va, vb, node, key))

            when :date
              va <=> vb
            when :number
              va <=> vb
            else
              compare_items(va, vb)
            end
        end

        result = -result unless key.ascending?
        result
      end

      def compare_items(a, b)
        sort_key(a) <=> sort_key(b)
      end

      def sort_key(string)
        string = string.to_s
        return collator.collation_key(string) unless collator.nil?

        folded = string.downcase(:fold)
        key = [folded.unicode_normalize(:nfd).gsub(/\p{Mn}/, ''), folded]
        sort_case_sensitively? ? key << string : key
      end

      def collator
        return unless defined?(ICU::Collation::Collator)

        lc = renderer.locale.to_s
        cs = sort_case_sensitively?

        @collators ||= {}
        @collators[[lc, cs]] ||= create_collator(lc, cs)
      end

      def create_collator(locale, case_sensitive)
        collator = ICU::Collation::Collator.new(locale)
        collator.case_first = :upper_first

        # Secondary strength compares letters and diacritics
        # but ignores case; tertiary strength considers case too.
        collator.strength = case_sensitive ? :tertiary : :secondary

        collator
      end

      def sort_case_sensitively?
        return false unless processor && processor.options
        processor.options[:sort_case_sensitively]
      end
    end
  end
end
