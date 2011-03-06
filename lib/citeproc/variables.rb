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
    
  class Variable
    include Attributes
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
    
    def to_s
      self.value.to_s
    end
    
    def is_numeric?
      self.to_s.match(/^-?\d+$/)
    end
    
    def <=>(other)
      strip_markup(self.to_s) <=> strip_markup(other.to_s)
    end
    
    protected
    
    def strip_markup(string)
      string.gsub(/<[^>]*>/, '')
    end
  end
  

  # == Name Variables
  #
  # When present in the item data, CSL name variables must be delivered as a
  # list of JavaScript arrays, with one array for each name represented by the
  # variable. Simple personal names are composed of family and given elements,
  # containing respectively the family and given name of the individual.
  #
  # { "author" : [
  #     { "family" : "Doe", "given" : "Jonathan" },
  #     { "family" : "Roe", "given" : "Jane" }
  #   ],
  #   "editor" : [
  #     { "family" : "Saunders",
  #       "given" : "John Bertrand de Cusance Morant" }
  #   ]
  # }
  #
  # Institutional and other names that should always be presented literally
  # (such as "The Artist Formerly Known as Prince", "Banksy", or "Ramses IV")
  # should be delivered as a single literal element in the name array:
  # 
  # { "author" : [
  #     { "literal" : "Society for Putting Things on Top of Other Things" }
  #   ]
  # }
  #
  # If the name is spelled using a 'byzantine' alphabet (i.e., latin or
  # cyrillic) its sort and display order is computed according to the given
  # arguments.
  #
  class Name < Variable

    # Based on the regular expression in citeproc-js
    ROMANESQUE = /^[a-zA-Z\u0080-\u017f\u0400-\u052f\u0386-\u03fb\u1f00-\u1ffe\.,\s'\u0027\u02bc\u2019-]*$/
    
    Variable.name_fields.each { |field| Variable.types[field] = Name }
    
    attr_fields %w{ given family literal suffix dropping-particle
      non-dropping-particle comma-suffix static-ordering parse-names }

    [[:last, :family], [:first, :given]].each do |m|
      alias_method m[0], m[1]
    end
    
    def defaults
      Hash['form', 'long', 'name-as-sort-order', 'false', 'demote-non-dropping-particle', 'display-and-sort']
    end
    
    def options
      @options ||= defaults
    end
    
    def merge_options(options)
      options.each_pair { |key, value| self.options[key] = value unless value.nil? }
    end
    
    def parse!(argument)
      return super unless argument.is_a?(String)
      parse_name!(argument)
    end
    
    def merge!(argument)
      if argument['parse-names'] && argument.delete('parse-names') != 'false'
        parse_family!(argument.delete('family'))
        parse_given!(argument.delete('given'))
      end
      
      argument.map { |key, value| self[key] = value }
    end
    
    def given
      initialize? ? to_initials(self['given']) : self['given']
    end
    
    def to_initials(name)
      return name if name.nil?
      
      name.split(/\s+|\.\s*/).map do |token|
        token.split(/-/).map do |part|
          # Keep all-lowercase names; otherwise keep only upper case letters
          part.match(/^[[:lower:]]+$/) ? part.center(part.length + 2) : part.scan(/[[:upper:]]/).join.capitalize + options['initialize-with']
        end.join(options['initialize-with-hyphen'] == 'false' ? '' : '-' ).gsub(/\s+-/, '-')
      end.join
    end
    
    # Parses a string and sets :family, :given, :suffix, and :particles
    # correspondingly.
    #
    # * non-dropping-particle: A string at the beginning of the family field
    #   consisting of spaces and lowercase roman or Cyrillic characters will
    #   be treated as a non-dropping-particle. The particles preceding some
    #   names should be treated as part of the last name, depending on the
    #   cultural heritage and personal preferences of the individual. To
    #   suppress parsing and treat such particles as part of the family name
    #   field, enclose the family name field content in double-quotes
    # * dropping-particle: A string at the end of the given name field
    #   consisting of spaces and lowercase roman or Cyrillic characters will
    #   be treated as a dropping-particle.
    # * suffix: Content following a comma in the given name field will be
    #   parse out as a name suffix. Modern typographical convention does not
    #   place a comma between suffixes such as "Jr." and the last name, when
    #   rendering the name in normal order: "John Doe Jr." If an individual
    #   prefers that the traditional comma be used in rendering their name,
    #   the comma can be force by placing a exclamation mark after the comma.
    #
    def parse_name!(string)
      return if string.nil?

      tokens = string.split(/,\s+/)

      parse_family!(tokens[0])
      parse_given!(tokens[1])
      
      self
    end
    
    # @see parse
    def parse_family!(string)
      return if string.nil?
      
      tokens = string.scan(/^['"](.+)['"]$|^([[:lower:]\s]+)?([[:upper:]][[:alpha:]\s]*)$/).first
            
      if tokens.nil?
        self['family'] = string
      else
        self['family'] = tokens[0] || tokens[2] || string
        self['non-dropping-particle'] = tokens[1].gsub(/^\s+|\s+$/, '') unless tokens[1].nil?
      end
      
      self
    end
    
    # @see parse
    def parse_given!(string)
      return if string.nil?

      tokens = string.scan(/^((?:[[:upper:]][[:alpha:]\.]*\s*)+)([[:lower:]\s]+)?(?:,!?\s([[:alpha:]\.\s]+))?$/).first

      if tokens.nil?
        self['given'] = string
      else
        self['given'] = (tokens[0] || string).gsub(/^\s+|\s+$/, '')
        self['dropping-particle'] = tokens[1] unless tokens[1].nil?
        self['suffix'] = tokens[2] unless tokens[2].nil?
        self['comma-suffix'] = 'true' if string.match(/,!/)
      end
      
      self
    end
    
    def is_personal?
      self.family?
    end
    
    def is_romanesque?
      (self['given'].nil? || self['given'].match(ROMANESQUE)) && (self['family'].nil? || self['family'].match(ROMANESQUE))
    end
    
    alias :is_byzantine? :is_romanesque?
        
    def comma_suffix
      self.comma_suffix? && self.suffix? ? comma : nil
    end
    
    def comma
      options['sort-separator'] || ', '
    end
    
    def delimiter
      is_romanesque? ? ' ' : ''
    end
    
    def value
      self
    end
    
    #
    # CSL1.0 Warning
    #
    # @returns true if, using the current options, the name's given name is
    # to be displayed using initials. Takes into account whether or not the
    # family name is set (if not, given name should not be turned to initials,
    # this is *not* sepcified in CSL 1.0).
    #
    def initialize?
      options.has_key?('initialize-with') && family? && is_romanesque?
    end
    
    def is_static_order?
      static_ordering? || !is_romanesque?
    end
    
    def is_sort_order?
      ['all', 'true', 'yes', 'always'].include?(options['name-as-sort-order'])
    end
 
    def is_numeric?
      false
    end
       
    # @returns a list of strings, representing a given order of the individual
    # tokens when displaying the name.
    def display_order(opts={})
      merge_options(opts)

      case
      when literal?
        return %w{ literal }
      
      when is_static_order?
        return %w{ family given }
        
      when options['form'] != 'short' && !is_sort_order?
        return %w{ given dropping-particle non-dropping-particle family comma-suffix suffix }

      when options['form'] != 'short' && is_sort_order? && ['never', 'sort-only'].include?(options['demote-non-dropping-particle'])
        return %w{ non-dropping-particle family comma given dropping-particle comma suffix }
    
      when options['form'] != 'short' && is_sort_order? && options['demote-non-dropping-particle'] == 'display-and-sort'
        return %w{ family comma given dropping-particle non-dropping-particle comma suffix }
    
      else # options['form'] == 'short'
        return %w{ non-dropping-particle family}
      end
      
    end
    
    # @returns a list of strings, representing the order of precedence of the
    # individual tokens when sorting the name.
    def sort_order(opts={})
      merge_options(opts)

      case
      when literal?
        return %w{ literal }
        
      when options['demote-non-dropping-particle'] == 'never'
        return %w{ non-dropping-particle+family dropping-particle given suffix }
      else
        return %w{ family non-dropping-particle+dropping-particle given suffix }
      end
    end
    
    # @returns a string representing the name according to the given set of
    # display order options.
    def display(opts={}, filters={})
      tokens = self.display_order(opts).map do |token|
        part = self.send(token.gsub(/-/,'_'))
        part = filters[token].apply_format(part) unless filters[token].nil?
        part
      end
      
      tokens.reject!(&:nil?)
      tokens.join(delimiter).squeeze(' ').gsub(/^[\s,]+|[\s,]+$|\s(,)/, '\1').squeeze(',')
    end
    
    def to_s
      self.display
    end
    
    def literal_as_sort_order
      literal.gsub(/^(the|an?|der|die|das|eine?|l[ae])\s+/i, '')
    end
    
    def <=>(other)

      tests = self.sort_order.zip(other.sort_order).map do |pair|
        this, that = pair.map { |token| token.gsub(/[\s-]+/,'_').gsub(/literal/, 'literal_sort_order') }          

        this = this.split(/\+/).map { |token| self.send(token) }.join.downcase
        that = that.split(/\+/).map { |token| other.send(token) }.join.downcase

        # TODO should we ignore '' here?
        this <=> that
      end

      tests = tests.reject(&:nil?)
      zeroes = tests.take_while(&:zero?)

      zeroes.length != tests.length ? tests[zeroes.length] : zeroes.empty? ? nil : 0
    end
  end


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
    
    def is_range?
      !to.empty?
    end
    
    def is_open_range?
      is_range? && to.uniq == [0]
    end
        
    def uncertain!
      self['circa'] = true
    end
    
    def bc?; year && year < 0; end
    def ad?; !bc? && year < 1000; end
    
    alias :is_uncertain? :circa?
    alias :is_season? :season?
    
    def from
      date_parts.first
    end
    
    def to
      date_parts[1] ||= []
    end
    
    def display(options={})
      options = defaults.merge(options)
      [year, month, day].compact.join(options['delimiter'])
    end
    
    def to_s
      literal || attributes.inspect
    end

    def value; self; end
    
    def is_numeric?; false; end
    
    def sort_order
      "%04d%02d%02d-%04d%02d%02d" % ((from + [0,0,0])[0,3] + (to + [0,0,0])[0,3])
    end
        
    def <=>(other)
      return nil unless other.is_a?(Date)
      self.sort_order <=> other.sort_order
    end
  end
end