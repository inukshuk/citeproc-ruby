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

module CSL::Format
  class Html < Default

    def initialize
      super
      @container = :span
      @mode = :individual
    end

    def self.filter(string)
      string.gsub(/&([^#])/i, '&#38;\1')
    end

    
    def finalize
      content = super
      if @styles.empty?
        content
      else
        @mode == :combined ? content_tag(@container, content, @styles) : individual_tags(content)
      end
    end

    def input=(input)
      super
      @tokens.each { |token| token.content = Html.filter(token.content) }
    end

    # @param display 'block', 'left-margin', 'right-inline', 'inline'
    def set_display(display)
      super
      @container = :div if !display.nil? && display != 'inline'
    end


    protected

    def individual_tags(content)
      @styles.each_pair do |style, value|
        case
        when style == 'font-weight' && value == 'bold'
          content = content_tag(:b, content)
        when style == 'font-style' && value == 'italic'
          content = content_tag(:i, content)
        end
      end
      
      content
    end
    
    def content_tag(name, content, styles=nil)
      if styles.nil?
        %Q{<#{name}>#{content}</#{name}>}
      else
        %Q{<#{name} style="#{ styles.map { |k,v| [[k,v].join(': ')].join('; ') } }">#{content}</#{name}>}
      end
    end
  end

end