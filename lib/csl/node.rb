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
  class Node
    include Support::Attributes
    include Support::Tree
    
    def initialize(arguments = {})
      parse(normalize(arguments[:node])) if arguments.has_key?(:node)
      yield self if block_given?
    end

    def name
      node_name || self.class.name.split(/::/).last.gsub(/([[:lower:]])([[:upper:]])/) { [$1, $2].join('-') }.downcase
    end

    def style!
      @style = root!.is_a?(Style) ? nil : root
    end

    def style; @style || style!; end

    def parse(node)      
      @node_name = node.name

      node.attributes.values.each { |a| attributes[a.name] = a.value }
      add_children(node.children.map { |child| Node.parse(child) })
    end

    def to_xml
    end

    protected

    def normalize(node)
      case node
      when Nokogiri::XML::Node
        node
      when String
        Nokogiri::XML.parse(node) { |config| config.strict.noblanks }.root
      else
        raise(ArgumentError, "failed to parse #{ node.inspect }")
      end
    end
  end

  end
end