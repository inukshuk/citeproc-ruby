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
  
  def merge!(argument)
    argument = [argument] unless argument.is_a?(Array)
    argument.each { |argument| self.attributes.merge!(argument) }
  end
  
  alias_method :to_hash, :attributes
  
  [:empty?, :map].each do |method_id|
    define_method method_id do |*args, &block|
      attributes.send(method_id, *args, &block)
    end
  end
  
  module ClassMethods
    def attr_fields(*args)
      args = args.shift if args.first.is_a?(Array)
      args.each do |field|
        field = field.to_s
        method_id = field.downcase.gsub(/[-\s]+/,'_')
        
        define_method method_id do; attributes[field]; end
        
        define_method [method_id, '='].join do |value|
          attributes[field] = value
        end
        
        define_method [method_id, '?'].join do
          !!(attributes[field] && !['', [], 'false'].include?(attributes[field]))
        end
        
      end
    end    
  end
  
end