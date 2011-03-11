#--
# CiteProc-Ruby
# Copyright (C) 2009-2011 Sylvester Keil <sylvester.keil.or.at>
# 
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
# 
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.	See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with this program.	If not, see <http://www.gnu.org/licenses/>.
#++

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
