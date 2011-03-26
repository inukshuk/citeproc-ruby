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

require 'forwardable'

module CiteProc
    
  class Variable
    extend Forwardable
    
    include Support::Attributes
    include Comparable

    @date_fields = %w{ accessed container event-date issued original-date }

    @name_fields = %w{
      author editor translator recipient interviewer publisher composer
      original-publisher original-author container-author collection-editor }

    @text_fields = %w{
      id abstract annote archive archive-location archive-place authority
      call-number chapter-number citation-label citation-number collection-title
      container-title DOI edition event event-place first-reference-note-number
      genre ISBN issue jurisdiction keyword locator medium note number
      number-of-pages number-of-volumes original-publisher original-publisher-place
      original-title page page-first publisher publisher-place references
      section status title URL version volume year-suffix }

    @filters = Hash.new
    
    @types = Hash.new(Variable)

    attr_fields :value
    
    def_delegators :value, :empty?, :to_s, :match
    
    class << self
      attr_reader :date_fields, :name_fields, :text_fields, :filters, :types

      def fields
        date_fields + name_fields + text_fields
      end
      
      def filter(id, key)
        Variable.filters[id][key]
      end

      def parse(values, name=nil)
        values.is_a?(Array) ? values.map { |value| Variable.types[name].new(value) } :
          Variable.types[name].new(values)
      end
    end

    def initialize(attributes={}, &block)
      parse!(attributes)
      yield self if block_given?
    end
    
    def parse!(argument)
      argument = argument.to_hash if argument.is_a?(Variable)
      argument.is_a?(Hash) ?  self.merge!(argument) : self.value = argument.to_s
    end
        
    def numeric?
      to_s =~ /\d/
    end
    
    # @returns (first) numeric data contained in the variable's value
    def to_i
      to_s =~ /(-?\d[\d,\.]*)/ && $1.to_i || 0
    end
    
    
    def <=>(other)
      strip_markup(self.to_s) <=> strip_markup(other.to_s)
    end
    
    protected
    
    def strip_markup(string)
      string.gsub(/<[^>]*>/, '')
    end
  end

end