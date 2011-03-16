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

require 'json'

module Support
  module Attributes
  
    def self.included(base)
      base.extend(ClassMethods)
    end
  
    attr_writer :attributes, :key_filter, :value_filter
  
    def attributes
      @attributes ||= {}
    end
  
    def [](id)
      attributes[filter_key(id)]
    end
  
    def []=(id, value)
      attributes[filter_key(id)] = filter_value(value)
    end
  
    def merge!(other)
      return self if other.nil?
      other.to_hash.each_pair { |k,v| self[k] = v }
      self
    end

    def reverse_merge!(other)
      other.merge!(self)
    end
  
    alias_method :to_hash, :attributes

    def empty?; attributes.empty?; end

    def key_filter
      @key_filter ||= Hash.new { |hash, key| hash[key] = key.to_s }
    end

    def value_filter
      @value_filter ||= Hash.new { |hash, key| hash[key] = key }
    end
  
    def to_json
      self.attributes.to_json
    end
  
    private
  
    def filter_key(key)
      key_filter[key] || key
    end
  
    def filter_value(value)
      value_filter[value] || value
    end
    
    module ClassMethods

      def attr_fields(*args)
        args.flatten.each do |field|
          field, default = (field.is_a?(Hash) ? field.to_a.flatten : [field]).map(&:to_s)
          method_id = field.downcase.gsub(/[-\s]+/, '_')
        
          define_method method_id do; self[field] ||= default; end unless self.respond_to?(method_id)
        
          writer_id = [method_id, '='].join
          define_method writer_id do |value|
            self[field] = value
          end unless self.respond_to?(writer_id)

          predicate = [method_id, '?'].join  
          unless self.respond_to?(predicate)
            define_method predicate do
              ![nil, false, '', [], 'false', 'no', 'never'].include?(self[field])
            end     
            has_predicate = ['has_', predicate].join
            alias_method(has_predicate, predicate) unless self.respond_to?(has_predicate)
          end
        end
      end
    
    end
  
  end
end