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
  
  module Format
    def self.default; CiteProc::Format::Default.new; end
  end
  
  class Formatter
  
    def format(*args)
      @format ||= CiteProc.default_format
      args.empty? ? @format : apply(args[0], args[1] || {})
    end

    def format=(format)
      @format = Format.const_get(format.to_s.split(/[\s_-]+/).map(&:capitalize).join).new
    rescue Exception => e
      CiteProc.log :warn, "failed to set format to #{ format.inspect }", e
    end
    
    def apply(input='', attributes={})
      return input if attributes.nil? || input.empty?

      format.input = input
      
      CSL::Nodes.formatting_attributes.each do |attribute|
        method_id = ['set', attribute.gsub(/-/, '_')].join('_')

        if attributes.has_key?(attribute) && format.respond_to?(method_id)
          format.send(method_id, attributes[attribute])
        end
      end
      
      format.finalize
    end
  
  end
  
end