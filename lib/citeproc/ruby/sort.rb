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

        # Sort values are computed only once per item
        # and key for the duration of the sort.
        cache = {}.compare_by_identity

        # TODO refactor
        if items.is_a?(CitationData)
          items.sort! do |a, b|
            compare_items_by_keys(a.data, b.data, keys, cache)
          end
        else
          items.sort! do |a, b|
            compare_items_by_keys(a, b, keys, cache)
          end
        end
      end

      private

      # @returns [-1, 0, 1, nil]
      def compare_items_by_keys(a, b, keys, cache)
        result = 0

        keys.each do |key|
          result = compare_items_by_key(a, b, key, cache)
          return result unless result.zero?
        end

        result
      end

      # @returns [-1, 0, 1, nil]
      def compare_items_by_key(a, b, key, cache)
        va, vb = sort_value(a, key, cache), sort_value(b, key, cache)

        # Return early if either side is nil.
        # In this case ascending/descending is irrelevant!
        return  0 if va.nil? && vb.nil?
        return  1 if va.nil?
        return -1 if vb.nil?

        result = va <=> vb
        result = -result unless key.ascending?
        result
      end

      def sort_value(item, key, cache)
        values = (cache[item] ||= {})
        values.fetch(key) { values[key] = compute_sort_value(item, key) }
      end

      def compute_sort_value(item, key)
        if key.macro?
          return sort_key(renderer.render_sort(item, key.macro, key))
        end

        value = item[key.variable]
        return if value.nil? || value.empty?

        case CiteProc::Variable.types[key.variable]
        when :names
          node = CSL::Style::Name.new(key.name_options)
          node.all_names_as_sort_order!

          sort_key(renderer.render_sort(value, node, key))

        when :date, :number
          value
        else
          sort_key(value)
        end
      end

      def sort_key(string)
        string = string.to_s

        collator = self.collator
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
