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

require 'date'

module CiteProc


  # == Date Variables
  #
  # Date objects wrap an underlying JavaScript object, within which the
  # "date-parts" element is a nested JavaScript array containing a start date
  # and optional end date, each of which consists of a year, an optional month
  # and an optional day, in that order if present. Additionally, the string
  # fields "season", "literal", as well as the boolean field "circa" are
  # supported. 
  #
  class Date < Variable

    attr_fields %w{ date-parts season circa literal }

    Variable.date_fields.each { |field| Variable.types[field] = Date }

    [:year, :month, :day].each_with_index do |method_id, index|
      define_method method_id do
        date_parts[0].nil? ? nil : date_parts[0][index]
      end
      
      define_method [method_id, '='].join do |value|
        date_parts[0] = [] if date_parts[0].nil?
        date_parts[0][index] = value.to_i
      end
    end
        
    def defaults
      Hash['delimiter', '-']
    end
    
    def parse!(argument)
      return super unless argument.is_a?(::Date) || argument.is_a?(String)
      parse_date!(date)
    end
    
    def merge!(argument)
      parse_date!(argument.delete('raw')) if argument.has_key?('raw')
      argument['date-parts'].map! { |parts| parts.map(&:to_i)  } if argument.has_key?('date-parts')
      super
    end
    
    def parse_date!(date)
      # TODO find out what the Ruby parser can do
      date = ::Date.parse(date) unless date.is_a?(::Date)
      date_parts[0] = [date.year, date.month, date.day]
      self
    end
    
    def date_parts
      attributes['date-parts'] ||= []
    end
    
    alias :parts :date_parts
    alias :parts= :date_parts=
    
    def range?
      parts[1] && !parts[1].empty?
    end
    
    def open_range?
      self.range? && parts[1].uniq == [0]
    end
        
    def uncertain!; self['circa'] = true; end
    
    def bc?; year && year < 0; end
    def ad?; !bc? && year < 1000; end
    
    alias :uncertain? :circa?
    
    def from
      parts[0] || []
    end
    
    def to
      Date.new('date-parts' => [parts[1] || []])
    end
    
    # @returns a value in 0..3 depending on how many of the date parts in the
    # range match.
    def range_match
      parts[0].zip(parts[1] || []).take_while { |p| p[0] == p[1] }.length
    end
    
    def display_parts
      rm = range_match

      case
      when !range? || open_range?
         [%w{day month year}, []]
      when rm == 1
        [%w{day month}, %w{day month year} ]
      when rm == 2
        [%w{day}, %w{day month year} ]
      else
        [%w{day month year}, %w{day month year} ]
      end
    end
    
    def display(options={})
      options = defaults.merge(options)
      from.compact.join(options['delimiter'])
    end
    
    def to_s
      literal || attributes.inspect
    end

    def value; self; end
    
    def numeric?; false; end
    
    def sort_order
      "%04d%02d%02d-%04d%02d%02d" % ((parts[0] + [0,0,0])[0,3] + ((parts[1] || []) + [0,0,0])[0,3])
    end
        
    def <=>(other)
      return nil unless other.is_a?(Date)
      [year, sort_order] <=> [other.year, other.sort_order]
    end
  end
  
end