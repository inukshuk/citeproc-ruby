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

module CiteProc

  class Processor
    
    attr_reader :style, :abbreviations, :format
    attr_accessor :language
    
    def initialize
      @bibliography = Bibliography.new
    end

    def style=(resource)
      @style = CSL::Style.new(resource)
    end
    
    def format=(new_format)
    end

    def items
      @items ||= {}
    end
    
    def import(items)
      items = to_a(items)
      items.each do |item|
        self.items[item['id']] = Item.new(item)
      end
    end
    
    def bibliography
    end
    
    def cite(ids, options={})
      ids = to_a(ids).map { |id| items[id] }
    end

    def nocite(ids, options={})
      @bibliography + to_a(ids).map { |id| items[id] }
    end

    alias :make_bibliography :bibliography
    alias :update_items :cite
    alias :update_uncited_items :nocite
    
    def render(item, layout)
      
    end
    
    private
    
    def to_a(attribute)
      attribute.is_a?(Array) ? attribute : [attribute]
    end
    
  end
  
end