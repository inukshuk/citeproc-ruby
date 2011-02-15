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

module CSL

  class Processor
    
    attr_reader :style, :bibliography, :abbreviations, :format
    attr_accessor :language, :registry
    
    def initialize
      @bibliography = Bibliography.new
      @registry = {}
    end

    def style=(resource)
      @style = Style.new(resource)
    end    
    
    def format=(new_format)
    end

    def register(items)
      items = [items] unless items.is_a?(Array)
      items.each do |item|
        registry[item['id']] = Item.parse(item)
      end
    end
    
    def cite
    end

    def nocite
    end
    
    def compile
    end
    
  end
end