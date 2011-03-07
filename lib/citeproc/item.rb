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

require 'observer'

module CiteProc

  class Item
    include Comparable
    include Observable
    include Attributes
    
    attr_fields Variable.fields
    attr_fields %w{ locator label suppress-author author-only prefix suffix }
    
    def initialize(attributes={}, filter=nil)
      self.merge!(attributes)
      yield self if block_given?
    end
    
    def self.filter(attributes, filter)
      # TODO
    end
    
    # @see CSL::Nodes::Group
    alias :access :[]
    def [](key)
      value = access(key)
      notify_observers(key, value)
      value
    end
    
    def merge!(other)
      other = other.attributes unless other.is_a?(Hash)
      other.each_pair { |key, value| self.attributes[key] = Variable.parse(value, key) }
      self
    end

    def reverse_merge!(other)
      other = other.attributes unless other.is_a?(Hash)
      other.each_pair { |key, value| self.attributes[key] ||= Variable.parse(value, key) }
      self
    end
    
    def to_s
      self.attributes.inspect
    end
    
    
    def <=>(other)
      self.attributes <=> other.attributes
    end
  end

end