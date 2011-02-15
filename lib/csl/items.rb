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

  module Item

    def self.included(base)
      base.extend(ClassMethods)
    end

    def self.parse(item)
      Hash[item.map { |key, value|
        [key, Date::FIELDS.include?(key) ? Date.new(value) : Name::FIELDS.include?(key) ? Name.new(value) : value]
      }]
    end
    
    attr_writer :attributes
    
    def attributes
      @attributes ||= {}
    end
    
    def [](id)
      attributes[id.to_s.downcase.gsub(/[-\s]+/,'_')]
    end
    
    def []=(id, value)
      attributes[id.to_s.downcase.gsub(/[-\s]+/,'_')] = value
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
      def fields(*args)
        args.each do |field|
          
          define_method field do; attributes[field.to_s]; end
          
          define_method [field, '='].join do |value|
            attributes[field.to_s]
          end
          
          define_method [field, '?'].join do
            !(attributes[field.to_s] || ["", [], 0].include?(attributes[field.to_s]))
          end
          
        end
      end    
    end
    
  end
  
  class Name
    
    FIELDS = %w{
      author editor translator recipient interviewer publisher composer
      original-publisher original-author container-author collection-editor
    }
    
    include Item
    
    fields :given, :family, :literal, :suffix, :dropping_particle,
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

    FIELDS = %w{ accessed container event-date issued original-date }

    include Item

    fields :date_parts, :season, :circa, :literal

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