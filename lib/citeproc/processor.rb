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
    
    attr_reader :style
    attr_writer :format
    
    def initialize
      @bibliography = Bibliography.new
    end

    def style=(resource)
      @style = CSL::Style.new(resource)
    end

    def language=(language)
      self.locale.set(language).language
    end
    
    def language
      self.locale.language
    end
    
    def locale
      @locale ||= CSL::Locale.new
    end
    
    def abbreviations
      @abbreviations ||= {}
    end
    
    def format
      @format ||= :default
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
    
    #
    # @param argument Symbol :all / or id of item
    # @param argument String  id of item
    # @param argument Array list of ids or items
    # @param id Hash must contain 'id'; optional: :label, :locator
    #
    # @returns a list of lists; [[1, 'Doe, 2000, p. 1'], ...]
    #
    def cite(argument)
      ids = extract_ids(argument)
      
      ids.map do |data|
        citation = @style.citation.process(items[data['id']], locale, format)
        [register(citation), citation]
      end
    end

    def nocite(ids, options={})
      @bibliography + to_a(ids).map { |id| items[id] }
    end

    alias :make_bibliography :bibliography
    alias :update_items :cite
    alias :update_uncited_items :nocite
    
        
    private
    
    def register(id)
      1
    end
    
    def to_a(attribute)
      attribute.is_a?(Array) ? attribute : [attribute]
    end
    
    # @returns a list of hashes [{ 'id' => 'id1' }, ... ]
    def extract_ids(argument)
      case
      when argument == :all
        self.items.keys.map { |id| { 'id' => id } }
      when argument.is_a?(Hash)
        argument.has_key?('id') ? [argument] : []
      when argument.is_a?(Array)
        argument.map { |element| extract_ids(element) }.flatten
      else
        self.items.has_key?(argument.to_s) ? [{ 'id' => argument.to_s }] : []
      end
    end
    
  end
  
end