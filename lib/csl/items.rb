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
  
  module Attributes

    def self.included(base)
      base.extend(ClassMethods)
    end
    
    attr_writer :attributes
    
    def attributes
      @attributes ||= {}
    end
    
    def [](id)
      attributes[id.to_s]
    end
    
    def []=(id, value)
      attributes[id.to_s] = value
    end
    
    def merge(argument)
      argument = [argument] unless argument.is_a?(Array)
      argument.each do |hash|
        raise(ArgumentError, "wrong argument type (#{hash.class.name} not Hash)") unless hash.is_a?(Hash)
        hash.keys.each do |key|
          attributes[key.to_s] = hash[key]
        end
      end
    end
    
    alias_method :to_hash, :attributes
    
    module ClassMethods
      def attr_fields(*args)
        args = args.shift if args.first.is_a?(Array)
        args.each do |field|
          field = field.to_s
          method_id = field.downcase.gsub(/[-\s]+/,'_')
          
          define_method method_id do; attributes[field]; end
          
          define_method [method_id, '='].join do |value|
            attributes[field]
          end
          
          define_method [method_id, '?'].join do
            !(attributes[field] || ["", [], 0].include?(attributes[field]))
          end
          
        end
      end    
    end
    
  end
  
  
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
    end
    
    def merge(attributes)
      attributes.map do |key, value|
        key = convert(key)
        self.attributes[key] = Item.date_fields.include?(key) ? Date.new(value) : Item.name_fields.include?(key) ? Name.new(value) : value
      end
    end
  
    # Converts a key (e.g., from BibTeX) to CSL syntax. @see converters.rb
    def convert(key)
      Item.converters.values.map { |c| c[key] }
    end
  end
  
  
  class Name       
    include Attributes
    
    attr_fields :given, :family, :literal, :suffix, :dropping_particle,
      :non_dropping_particle, :comma_suffix, :static_ordering, :parse_names

    [[:last, :family], [:first, :given]].each do |m|
      alias_method m[0], m[1]
    end
    
    def initialize(attributes={})
      set(attributes)
      yield self if block_given?
    end
    
    def set(name)
      name.is_a?(String) ? literal = name : merge(name)
    end
    
    def to_s
      literal || [given, non_dropping_particle || dropping_particle, [family, comma_suffix? && suffix ? ',' : ''].join, suffix].reject(&:nil?).join(' ')
    end
  end

  class Date
    include Attributes

    attr_fields :date_parts, :season, :circa, :literal

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