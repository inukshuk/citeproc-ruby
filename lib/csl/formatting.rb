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
  
  module Formatting
    
    def self.included(base)
      base.extend(ClassMethods)
    end
    
    module ClassMethods
      
      def format(formatter)
        formatter = CSL::Format.const_get(formatter.to_s.split(/[\s_-]+/).map(&:capitalize).join)
        
        define_method :format do |string|
          Node.formatting_attributes.each do |attribute|
            method_id = ['set', attribute.gsub(/-/, '_')].join('_')
            if attributes.has_key?(attribute) && formatter.respond_to?(method_id)
              string = formatter.send(method_id, string, attributes[attribute])
            end
          end
          string
        end
        
      end
      
    end    
  end
  
  module Format
    
    class Default
      
      def self.set_prefix(string, prefix)
        [prefix, string].join
      end

      def self.set_suffix(string, suffix)
        [string, suffix].join
      end
      
      # @param display 'block', 'left-margin', 'right-inline', 'inline'
      def self.set_display(string, display)
        string
      end
      
      def self.set_strip_periods(string, strip)
        strip && strip != 'false' ? string.gsub(/\./, '') : string
      end
            
      # @param style 'normal', 'italic', 'oblique' 
      def self.set_font_style(string, style='normal')
        string
      end
      
      # @param variant 'normal', 'small-caps'
      def self.set_font_variant(string, variant='normal')
        variant == 'small-caps' ? string.upcase : string
      end
   
      # @param weight 'normal', 'bold', 'light' 
      def self.set_font_weight(string, weight='normal')
        string
      end

      # @param decoration 'none', 'underline'
      def self.set_text_decoration(string, decoration='none')
        string
      end

      # @param align 'baseline', 'sub', 'sup' 
      def self.set_vertical_align(string, align='baseline')
        string
      end

      # @param case 'lowercase', 'uppercase', 'capitalize-first', 'capitalize-all', 'title', 'sentence'
      def self.set_text_case(string, text_case)
        case text_case
        when 'lowercase' then string.downcase
        when 'uppercase' then string.upcase
        when 'capitalize-first' then string.capitalize
        when 'capitalize-all' then string.split(/(\s+)/).map(&:capitalize).join
          # TODO 'title' must be localized
        when 'title' then string.capitalize.split(/(\s+)/).map { |word| word.match(/^(and|of|in|is|a|an|the)$/) ? word : word.capitalize }.join
          # TODO
        when 'sentence' then string.capitalize
        else
          string
        end
      end
         
    end
    
  end
end