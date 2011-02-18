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

  class Item
    include Attributes
    
    attr_fields CSL::Variable.fields
    
    def initialize(attributes={}, filter=nil)
      self.merge!(attributes)
      yield self if block_given?
    end
    
    def self.filter(attributes, filter)
      # TODO
    end
    
    def merge!(arguments)
      arguments = [arguments] unless arguments.is_a?(Array)
      arguments.each { |argument| argument.map { |key, value| self.attributes[key] = CSL::Variable.parse(value, key) }}
    end
    
  end

end