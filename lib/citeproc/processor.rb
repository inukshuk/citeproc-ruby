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
      yield self if block_given?
    end

    def self.process(item, options={})
      return '' if item.nil? || item.empty?
      
      processor = Processor.new do |p|
        p.style = options['style'] || CSL.default_style
        p.locale = options['locale'] || CSL.default_locale
        p.import(item)
      end

      if options[:mode] == :citation
        processor.cite(:all)[0][1]
      else
        processor.bibliography.data.join
      end
    end
    
    def style=(resource)
      @style = resource.is_a?(CSL::Style) ? resource : CSL::Style.new(resource)
    end

    def language=(language)
      self.locale.set(language).language
    end
    
    def language
      self.locale.language
    end
    
    def locale=(locale)
      @locale = locale.is_a?(CSL::Locale) ? locale : CSL::Locale.new(locale)
    end
    
    def locale
      @locale ||= CSL.default_locale
    end
    
    # @returns the abbreviations, a self-recording hash.
    def abbreviations
      @abbreviations ||= new_abbreviations
    end
    
    alias :transfrom :abbreviations
    
    def abbreviations=(abbreviations)
      @abbreviations = new_abbreviations
      add_abbreviations(abbreviations)
    end
    
    def add_abbreviations(abbreviations)
      abbreviations.keys.each do |list|
        abbreviations[list].keys.each do |category|
          abbreviations[list][category].each_pair do |long, short|
            self.abbreviations[list] ||= new_self_recording_hash
            self.abbreviations[list][category][long] = short
          end
        end
      end
    end
        
    def abbreviate(category, name, list='default')
      self.abbreviations[list][category][name]
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
        item = Item.new(item)
        self.items[item['id'].to_s] = item
      end
    end
    
    def bibliography(*args)
      data = extract_citation_data(:all)
      data.populate!(items)
      
      data = @style.bibliography.process(data, self)
      Bibliography.new(data)
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
      data = extract_citation_data(data)

      data.populate!(items)
      citation = @style.citation.process(data, self)
      
      [[register(citation), citation]]
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
        argument = items.keys.map { |id| { 'id' => id } }
                
      when items.has_key?(argument.to_s)
        argument = { 'id' => argument.to_s }
        
      end

      CitationData.new(argument)
    end
    
    def new_abbreviations
      { 'default' => new_self_recording_hash }
    end
    
    def new_self_recording_hash
      Hash.new { |h,k| h[k] = Hash.new { |h,k| h[k] = k } }
    end
  end
  
end