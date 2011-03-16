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

module Support
  module Tree
        
    attr_accessor :parent, :node_name
    
    def name
      node_name || self.class.name.split(/::/).last.gsub(/([[:lower:]])([[:upper:]])/) { [$1, $2].join('-') }.downcase
    end
    
    def children
      @children ||= []
    end

    def has_children?; !children.empty?; end
    
    def descendants!
      @descendants = children + children.map(&:children).flatten
    end
    
    def descendants; @descendants || descendants!; end
    
    def add_children(*args)
      args = args.shift if args.length == 1 && args[0].is_a?(Array)
      args.each { |node| node.parent = self; children << node }
      self
    end
    
    def ancestors!
      @ancestors = root? ? [] : [parent] + parent.ancestors!
    end

    def ancestors; @ancestors || ancestors!; end
    
    def depth
      ancestors.length
    end
    
    def root!
      @root = root? ? self : parent.root!
    end

    def root; @root || root!; end
    
    def root?; parent.nil?; end
    
    def to_xml
    end
    
  end
end