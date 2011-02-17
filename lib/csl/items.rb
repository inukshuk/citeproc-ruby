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
    
  class Item
    include Attributes

    @date_fields = %w{ accessed container event-date issued original-date }

    @name_fields = %w{
      author editor translator recipient interviewer publisher composer
      original-publisher original-author container-author collection-editor }

    @text_fields = %w{
      id abstract annote archive archive-location archive-place authority
      call-number chapter-number citation-label citation-number collection-title
      container-title DOI edition event event-place first-reference-note-number
      genre ISBN issue jurisdiction keyword locator medium note number
      number-of-pages number-of-volumes original-publisher original-publisher-place
      original-title page page-first publisher publisher-place references
      section status title URL version volume year-suffix }
    
    @converters = Hash.new
    
    class << self
      attr_reader :date_fields, :name_fields, :text_fields, :converters
      
      def fields
        date_fields + name_fields + text_fields
      end
    end
    
    attr_fields Item.fields
    
    def initialize(attributes={})
      merge(attributes)
      yield self if block_given?
    end
    
    def merge(hash)
      hash.map do |key, value|
        attributes[key] = Item.date_fields.include?(key) ? Variables::Date.new(value) : Item.name_fields.include?(key) ? Variables::Name.parse(value) : value.to_s
      end
    end
  
    # Converts a key (e.g., from BibTeX) to CSL syntax. @see converters.rb
    def convert(key)
      Item.converters.values.map { |c| c[key] }.first
    end
  end
  
  module Variables
    class Name
      include Comparable
      include Attributes
    
      attr_fields %w{ given family literal suffix dropping-particle
        non-dropping-particle comma-suffix static-ordering parse-names }

      [[:last, :family], [:first, :given]].each do |m|
        alias_method m[0], m[1]
      end

      def self.parse(names)
        names = [names] unless names.is_a?(Array)
        names.map { |name| Name.new(name) }
      end
      
      def initialize(attributes={})
        set(attributes)
        yield self if block_given?
      end
    
      def set(name)
        name.is_a?(String) ? literal = name : merge(name)
      end

      def display_order(options={})
        case
        when options['form'] == 'long' && options['name-as-sort-order'] == 'false'
          return [given, dropping_particle, non_dropping_particle, [family, comma_suffix? && suffix ? ',' : ''].join, suffix]

        when options['form'] == 'long' && options['name-as-sort-order'] == 'true' && ['never', 'sort-only'].include?(options['demote-non-dropping-particle'])
          return [non_dropping_particle, family, given, dropping_particle, suffix]
      
        when options['form'] == 'long' && options['name-as-sort-order'] == 'true' && options['demote-non-dropping-particle'] == 'display-and-sort'
          return [family, given, dropping_particle, non_dropping_particle, suffix]
      
        else # options['form'] == 'short'
          return [non_dropping_particle, family]
        end
      end
      
      def sort_order(options={})
        case
        when options['demote-non-dropping-particle'] == 'never'
          return [[non_droppping_particle, family].reject(&:nil?).join(' '), dropping_particle, given, suffix]
        else
          return [family, [non_dropping_particle, dropping_particle].reject(&:nil?).join(' '), given, suffix]
        end
      end
      
      def to_s
        literal || [given, non_dropping_particle || dropping_particle, [family, comma_suffix? && suffix ? ',' : ''].join, suffix].reject(&:nil?).join(' ')
      end
      
      def <=>(other)
        self.to_s <=> other.to_s
      end
    end

    class Date
      include Attributes

      attr_fields %w{ date-parts season circa literal }

      [:year, :month, :day].each_with_index do |method_id, index|
        
        define_method method_id do; date_parts[index] end
        
        define_method [method_id, '='].join do |value|
          date_parts[index] = value.to_i
        end
        
      end
      
      def initialize(attributes={})
        @attributes = {}.merge(attributes)      
        yield self if block_given?
      end

      # @param date
      # @param from_date, to_date
      def set(*args)
        raise(ArgumentError, "wrong number of arguments (#{args.length} for 1..2)") unless (1..2).include?(args.length)
        date_parts = args.map { |date| [:year, :month, :day].map { |part| date.nil? ?  0 : date.send(part) } }
      end
    
      def to_s
        literal || attributes.inspect
      end
    
    end
  end
  
end