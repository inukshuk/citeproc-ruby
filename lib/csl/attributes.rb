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
            attributes[field] = value
          end
          
          define_method [method_id, '?'].join do
            !!(attributes[field] && !["", [], 0].include?(attributes[field]))
          end
          
        end
      end    
    end
    
  end
end