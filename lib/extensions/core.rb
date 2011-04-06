
# ---------- Open Class ----------

module Kernel
  alias :is_an? :is_a? unless defined?(is_an?)
end


# ---------- Extensions ----------

module Extensions
  module Core
  
    module Numbers
      MAX_ROMAN = 4999
      FACTORS = [["M", 1000], ["CM", 900], ["D", 500], ["CD", 400],
      ["C",  100], ["XC",  90], ["L",  50], ["XL",  40],
      ["X",   10], ["IX",   9], ["V",   5], ["IV",   4],
      ["I",    1]]

      # Returns roman equivalent of the integer
      # This function is featured in the pickaxe book
      def romanize
        num = self.to_i
        roman = ""
        unless num < 1 || num > MAX_ROMAN
          for code, factor in FACTORS
            count, num = num.divmod(factor)
            roman << (code * count)
          end
        end
        roman.downcase
      end

    end
  end
end

# ---------- Include extensions ----------

class Fixnum
  include Extensions::Core::Numbers
end
