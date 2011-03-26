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

  class Selector
    include Support::Attributes
    
    attr_fields :select, :include, :exclude, :quash
    
    
    def initialize(argument = {})
      key_filter['all'] = 'select'
      key_filter['any'] = 'include'
      key_filter['none'] = 'exclude'
      
      merge(normalize(argument))
    end
    
    def type
      attributes.keys.detect { |k| [:select, :include, :exclude].include?(k.to_sym) }
    end
    
    # @returns one of :all?, :any?, :none?
    def matcher
      type == 'include' ? :any? : type == 'exclude' ? :none? : :all?
    end
    
    def conditions
      attributes[type] || []
    end
    
    def to_proc
      Proc.new do |item|
        conditions.send(matcher) { |c| item[c['field']] == c['value'] }
      end
    end
        
    protected
    
    def normalize(argument)
      case
      when [String, Symbol].include?(argument.class) && !(argument.to_s =~ /^\s*\{/)
        { argument.to_s => [] }
      else
        argument
      end
    end
    
  end

end