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

    attr_reader :input
    
    def input=(input)
      @input = input
      @style = {}
      @container = :span
    end

    def finalize
      @style.empty? ? @input : %Q{<#{@container} style="#{@style.map { |k,v| [k,v].join(': ') }.join('; ') }">#{@input}</#{@container}>}
    end


    # @param display 'block', 'left-margin', 'right-inline', 'inline'
    def set_display(display)
      #TODO
    end

    # @param style 'normal', 'italic', 'oblique' 
    def set_font_style(style='normal')
      @style['font-style'] = style
    end

    # @param variant 'normal', 'small-caps'
    def set_font_variant(variant='normal')
      @style['font-variant'] = variant
    end

    # @param weight 'normal', 'bold', 'light' 
    def set_font_weight(weight='normal')
      @style['font-weight'] = weight
    end

    # @param decoration 'none', 'underline'
    def set_text_decoration(decoration='none')
      @style['text-decoration'] = decoration
    end

    # @param align 'baseline', 'sub', 'sup' 
    def set_vertical_align(align='baseline')
      @style['vertical-align'] = align
    end

    # @param case 'lowercase', 'uppercase', 'capitalize-first', 'capitalize-all', 'title', 'sentence'
    def set_text_case(text_case)
      case text_case
      when 'lowercase'
        @style['text-transform'] = 'lowercase'

      when 'uppercase'
        @style['text-transform'] = 'uppercase'

      when 'capitalize-first'
        @input = @input.capitalize

      when 'capitalize-all'
        @style['text-transform'] = 'capitalize'

        # TODO 'title' must be localized
      when 'title'
        @input = @input.capitalize.split(/(\s+)/).map { |word| word.match(/^(and|of|in|is|a|an|the)$/) ? word : word.capitalize }.join

        # TODO
      when 'sentence'
        @input = @input.capitalize
      else
        # nothing
      end
    end

  end

end