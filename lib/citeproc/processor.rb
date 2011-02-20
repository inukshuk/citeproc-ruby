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
    # @param data Symbol :all / or id of item
    # @param data String  id of item
    # @param data Array list of ids or citation data
    # @param data Hash citation data or citation items
    #
    # @returns a list of lists; [[1, 'Doe, 2000, p. 1'], ...]
    #
    def cite(data)
      data = extract_citation_data(data) unless data.kind_of?(CitationData)

      data.map do |data|
        # item = self.items[data['id']]
        # CiteProc.log.warn "no item available for citation data #{datum.inspect}" unless item
        
        citation = @style.citation.process(data, self)
        
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
    
    # @returns a citation data object
    def extract_citation_data(argument)
      case
      when argument == :all
        CitationData.new('citation-items' => self.items.keys.map { |id| { 'id' => id } })
      when argument.is_a?(Array)
        CitationData.new('citation-items' => argument.map { |id| { 'id' => id } })
      when argument.is_a?(Hash)
        CitationData.new(argument)
      else
        self.items.has_key?(argument.to_s) ? CitationData.new('citation-items' => [{ 'id' => argument.to_s }]) : CitationData.new
      end
    end
    
  end
  
end