module CiteProc
  module Ruby

    class Format

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

      def apply(string, node)
        string, options = string.dup, node.formatting_options

        string.prepend(options[:prefix]) if options.key?(:prefix)
        string.concat(options[:suffix]) if options.key?(:suffix)

        string
      end
    end

  end
end
