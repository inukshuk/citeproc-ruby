module CiteProc
  module Ruby
    module Formats

      class Text < Format

        private

        def finalize!
          super
          output.gsub!(/&(amp|lt|gt);/i, {
            '&amp;' => '&',
            '&gt;'  => '>',
            '&lt;'  => '<'
          })
        end

      end

      class Debug < Format
      end

    end
  end
end
