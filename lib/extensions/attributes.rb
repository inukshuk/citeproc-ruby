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

# module LazyAttributes
#   def self.included(base)
#     base.extend(ClassMethods)
#   end
# 
#   module ClassMethods
#     
#     def attr_lazy(*args)
#       args.each do |attribute_name, initial_value|
#         define_method attribute_name do
#           self.instance_eval("@#{attribute_name} ||= #{initial_value.inspect}")
#         end
#       end
#     end
#   end
#   
# end

require 'json'

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
  
  def merge!(argument)
    argument.map { |key, value| self[key] = value }
  end
  
  alias_method :to_hash, :attributes
  
  [:empty?, :map].each do |method_id|
    define_method method_id do |*args, &block|
      attributes.send(method_id, *args, &block)
    end
  end

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
      args = args.shift if args.first.is_a?(Array)
      args.each do |field|
        field = field.to_s
        method_id = field.downcase.gsub(/[-\s]+/,'_')
        
        define_method method_id do; self[field]; end
        
        define_method [method_id, '='].join do |value|
          self[field] = value
        end
        
        define_method [method_id, '?'].join do
          !!(self[field] && !['', [], 'false'].include?(attributes[field]))
        end
        
      end
    end
    
  end
  
end