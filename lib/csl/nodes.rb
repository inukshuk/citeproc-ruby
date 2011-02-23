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

  class Nodes

    @formatting_attributes = %w{ text-case font-style font-variant font-weight
      text-decoration vertical-align prefix suffix display strip-periods  }

    @inheritable_name_attributes = %w{ and delimiter-precedes-last et-al-min
      et-al-use-first et-al-subsequent-min et-al-subsequent-use-first
      initialize-with name-as-sort-order sort-separator }
  
    class << self; attr_reader :formatting_attributes, :inheritable_name_attributes; end
    
    # == Node
    #
    # A Node represents a CSL rendering element.
    # Rendering elements are used to specify which, and in what order,
    # bibliographic data should be included in citations and bibliographies.
    # Rendering elements also partly control the formatting of this data.
    #
    # Each Node is bound to a node in a CSL Style document. Furthermore,
    # before any processiong can be done, the Node must be linked with a
    # processor, in order to be able to access items, format, or locale
    # information.
    #
    class Node
      include Attributes
      include Formatting

      attr_reader :node, :style, :processor
      attr_accessor :processor
    
      def initialize(node, style, processor=nil)
        @node = node
        @style= style
        self.processor = processor
        self.parse_attributes      
      end

      # Parses the given node an returns a new instance of Node or a suitable
      # subclass corresponding to the node's name
      def self.parse(node, style, processor=nil)
        name = node.name.split(/[\s-]+/).map(&:capitalize).join
        klass = CSL::Nodes.const_defined?(name) ? CSL::Nodes.const_get(name) : CSL::Nodes::Node
        klass.new(node, style, processor)
      end
    
      # @returns the item with the given id (registered with the associated
      # processor) or an empty item
      def item(id)
        (@processor && @processor.items[id]) || CiteProc::Item.new
      end
      
      def locale
        (@processor && @processor.locale) || Locale.new
      end
      
      def processor=(processor)
        @processor = processor
        self.format = processor.format unless processor.nil?
      end
      
      # Processes the supplied data.
      def process(data, processor=nil)
        self.processor = processor unless processor.nil?
      end
    
    
      protected
    
      def parse_attributes
        node.attributes.values.each { |a| attributes[a.name] = a.value }
      end

      # Attributes for the cs:names and cs:name elements may also be set on
      # cs:style, cs:citation and cs:bibliography. This eliminates the need to
      # repeat the same attributes and attribute values for every occurrence
      # of the cs:names and cs:name elements.
      #
      # The available inheritable attributes for cs:name are and,
      # delimiter-precedes-last, et-al-min, et-al-use-first,
      # et-al-subsequent-min, et-al-subsequent-use-first, initialize-with,
      # name-as-sort-order and sort-separator. The attributes name-form and
      # name-delimiter accompany the form and delimiter attributes on cs:name.
      # Similarly, names-delimiter, the only inheritable attribute available
      # for cs:names, accompanies the delimiter attribute on cs:names.
      #
      # When an inheritable name attribute is set on cs:style, cs:citation or
      # cs:bibliography, its value is used for all cs:names elements within
      # the element carrying the attribute. When an element lower in the
      # hierarchy includes the same attribute with a different value, this
      # latter value will override the value(s) specified higher in the
      # hierarchy.
      #
      # This mehtod traverses a nodes ancestor chain and inherits all
      # specified attributes from each parent that matches a name in names.
      #
      def inherit_attributes_from(nodes=[], attributes=[], prefix='')
        return unless @node
        
        parent = @node.parent        
        until parent.name == 'document' do
          attributes.each { |attribute| self[attribute] ||= parent[[prefix, attribute].join] } if nodes.include?(parent.name)
          parent = parent.parent
        end

      end
    end

    # Represents a cs:citation or cs:bibliography element.
    class Renderer < Node
    
      attr_fields Nodes.inheritable_name_attributes

      attr_reader :layout
    
      def initialize(node, style, processor=nil)
        super
        @layout = Node.parse(node.at_css('layout'), style, processor)
      end
    
      def sort
        # TODO
      end

      def process(data, processor=nil)
        super
        @layout.process(data, processor)
      end
      
    end

    class Bibliography < Renderer
      attr_fields %w{ hanging-indent second-field-align line-spacing
        entry-spacing subsequent-author-substitute }
    end

    class Citation < Renderer
      attr_fields %w{ collapse year-suffix-delimiter after-collapse-delimiter
        near-note-distance disambiguate-add-names disambiguate-add-given-name
        given-name-disambiguation-rule disambiguate-add-year-suffix }
    end
    
    # All the rendering elements that should appear in the citations and
    # bibliography should be nested inside the cs:layout element. Itself a
    # rendering element, cs:layout accepts both affixes and formatting
    # attributes. When used in the cs:citation element, a delimiter can be set
    # to separate multiple bibliographic items in a single citation.
    class Layout < Node
      attr_fields Nodes.formatting_attributes
      attr_fields %w{ delimiter }

      def initialize(node, style, processor=nil)
        super
        node.children.each { |n| self.elements.push(Node.parse(n, style, processor)) }
      end
    
      def elements
        @elements ||= []
      end

      def process(data, processor=nil)
        super
        self.elements.map { |element| element.process(data, processor) }.join(delimiter)
      end

      format_on :process
    end
  
    class Macro < Layout
      attr_fields :name
    end

    # The cs:text element is used to output text, which can originate from
    # different sources. The source-type is indicated with an attribute, and
    # the attribute value acts as an identifier within the source-type. For
    # example,
    #
    # <text variable="title" form="short" font-style="italic"/>
    #
    # indicates that the source-type is a variable, and that the variable that
    # should be displayed is the italicized short form of "title". The
    # different source-types are:
    #
    # * variable - the text contents of a variable (see Standard Variables). The
    #   optional form attribute can be set to either "long" (the default) or
    #   "short" to select the long or short forms of variables, e.g. the full
    #   and short title.
    # * macro - the text generated by a macro. The value of macro should
    #   correspond to the value of the name attribute of the desired cs:macro
    #   element.
    # * term - the text of a localized term (see Appendix III - Terms and
    #   Locale). The plural attribute can be set to choose either the singular
    #   (value "false", the default) or plural variant (value "true") of a term.
    #   In addition, the form attribute can be set to select the desired term
    #   form ("long" [default], "short", "verb", "verb-short" or "symbol"). If
    #   for a given term the desired form does not exist, another form may be
    #   used: "verb-short" reverts to "verb", "symbol" reverts to "short", and
    #   "verb" and "short" both revert to "long".
    # * value - used to output verbatim text, which is set via the value of
    #   value (e.g. value="some text")
    #
    # In all cases the attributes for affixes, display, formatting, quotes,
    # strip-periods and text-case may be applied to cs:text.    
    class Text < Node
      attr_fields Nodes.formatting_attributes
      attr_fields %w{ variable form macro term plural value quotes }
    
      def process(data, processor=nil)
        super

        case
        when self.value?
          text = self.value
        when self.macro?
          text = @style.macros[macro].process(data, @processor) 
        when self.term?
          text = self.locale[term].to_s(attributes)
        when self.variable?
          item = self.item(data['id'])
          text = (data[variable] || item["short#{variable.capitalize}"] || item[['short', variable].join('-')] || item[variable]).to_s
          
          if self.form == 'short'
            text = abbreviate(text)
          end
          
          if self.variable == 'page' && @style.options.has_key?('page-range-format')
            text = format_page_range(text, @style.options['page-range-format'])
          end
          
        else
          ''
        end
        
        # Add localized quotes
        text = [self.locale['open-quote'], text, self.locale['close-quote']].join if quotes?
      
        text
      end
  
      format_on :process
      
      protected
      
      def abbreviate(value)
        @processor.abbreviate(variable, value)
      end

      
      # The page abbreviation rules for the different values of the
      # page-range-format attribute on cs:style are:
      # 
      # * "minimum": All digits repeated in the second number are left out:
      #   42-5, 321-8, 2787-816
      # * "expanded": Abbreviated page ranges are expanded to their
      #   non-abbreviated form: 42-45, 321-328, 2787-2816
      # * "chicago": Page ranges are abbreviated according to the link Chicago
      #   Manual of Style-rules
      #     
      def format_page_range(value, format)
        return value unless value.match(/([a-z]*)(\d+)\s*\D\s*([a-z]*)(\d+)/i)

        tokens = [$1, $2, "\u2013", $3, $4]

        # normalize page range to expanded form
        f, t = tokens[1].chars.to_a, tokens[4].chars.to_a
        d = t.length - f.length
        d > 0 ? d.times { f.unshift('0') } : t = f.take(d.abs) + t
        
        # TODO handle prefixes correctly
        # TODO handle multiple ranges
        
        case format
        when /mini/
          tokens[4] = f.zip(t).map { |f, t| f == t ? nil : t }.reject(&:nil?)
          tokens[3] = nil if tokens[3] == tokens[0]
        when 'expanded'
          tokens[4] = t
          tokens[3] = tokens[0] if tokens[3].nil? || tokens[3].empty?
        when 'chicago'
          case
          when f.length < 3 || f.join.to_i % 100 == 0
            # use all digits
            tokens[4] = t
            tokens[3] = tokens[0] if tokens[3].nil? || tokens[3].empty?            
          when f.join.to_i % 100 < 10
            # use changed part only
            tokens[4] = f.zip(t).map { |f, t| f == t ? nil : t }.reject(&:nil?)
            tokens[3] = nil if tokens[3] == tokens[0]
          when f.length == 4
            # use at least two digits, and all if three or more change
            match = f[0..-3].zip(t[0..-3]).map { |f, t| f == t ? nil : t }.reject(&:nil?) + t[-2..-1]
            tokens[4] = match.length > 2 ? t : match
            tokens[3] = tokens[0] if tokens[3].nil? || tokens[3].empty?
          else
            # use at least two digits in second number
            tokens[4] = f[0..-3].zip(t[0..-3]).map { |f, t| f == t ? nil : t }.reject(&:nil?) + t[-2..-1]
            tokens[3] = nil if tokens[3] == tokens[0]
          end
        else
          value
        end
        tokens.join
      end
      
    end


    # The cs:date element is used to output dates, in either a localized or a
    # non-localized format. The desired date variable (see Date Variables) is
    # selected with the variable attribute.
    #
    # Localized date formats are selected with the form attribute. This
    # attribute can be set to "numeric" (for numeric date formats, e.g.
    # "12-15-2005"), or to "text" (for date formats with a non-numeric month,
    # e.g. "December 15, 2005"). Localized dates can be customized in two
    # ways. First, the date-parts attribute may be used to specify which
    # cs:date-part elements are shown. The possible values are:
    #
    # * "year-month-day" - default, displays year, month and day
    # * "year-month" - displays year and month
    # * "year" - displays year only
    #
    # Secondly, cs:date may include one or more cs:date-part elements (see
    # Date-part). The attributes set on these elements override those
    # originally specified for the localized date formats (e.g. the form
    # attribute of the month-cs:date-part element can be set to "short" to get
    # abbreviated month names in all locales.). Note that the use of
    # cs:date-part elements for localized dates does not affect which, and in
    # what order, the cs:date-part elements are included in the rendered date.
    # Also, the cs:date-part elements may not carry the attributes for
    # affixes, as these are considered to be locale-specific.
    #
    # Non-localized date formats are self-contained: the date format is
    # entirely controlled by cs:date and its cs:date-part children. In
    # contrast to localized dates, cs:date is used without the form and
    # date-parts attributes. Only the included cs:date-part elements will be
    # rendered, in the order in which they are specified. The cs:date-part
    # elements may carry attributes for both affixes and formatting, while
    # cs:date may carry a delimiter (delimiting the various cs:date-part
    # elements).
    #
    # For both localized and non-localized dates, affixes, display and
    # formatting attributes may be specified for the cs:date element.
    class Date < Node
      attr_fields Nodes.formatting_attributes
      attr_fields %w{ variable form date-parts delimiter }

      def process(data, processor=nil)
        super
        date = self.item(data['id'])[variable]
        
        case
        when date.nil?
          ''
        when date.literal?
          date.literal
        else
          self.parts.map { |part| part.process(date, processor) }.join(delimiter)
        end
      end

      format_on :process
    
      def parts
        if self.form?
          collect(DatePart.parse(self.locale.date[form]), DatePart.parse(@node.children))
        else
          DatePart.parse(@node.children)
        end
      end
    
      # Combines two lists of date-part elements. Attributes in the second
      # list take precedence over attributes in corresponding elements in the
      # first list.
      # 
      # @returns the consolidated list
      #
      def collect(p1, p2)
      
        # merge
        parts = p1.empty? ? p2 : p1.map do |this|
          that = p2.detect { |part| part['name'] == this['name'] }
          this.attributes = this.attributes.merge(that.attributes) unless that.nil?
          this
        end
      
        # filter
        filter = %w{ year month day } & (date_parts? ? date_parts.split(/-/) : %w{ year month day })
        parts = parts.reject { |part| !filter.include?(part['name']) }
      end

    end

    class DatePart < Node
      attr_fields Nodes.formatting_attributes
      attr_fields %w{ name form range-delimiter strip-periods }
    
      def self.parse(nodes)
        return [] if nodes.empty?
        nodes.map { |n| DatePart.new(n, @style, @processor) }
      end    
    
      def process(date, processor=nil)
        super
        
        part = case self['name']
          when 'day'
            case form
            when 'ordinal' then locale.ordinalize(date.day)
            when 'numeric-leading-zeros' then "%02d" % date.day
            else # 'numeric'
              date.day.to_s
            end
          when 'month'
            if date.season?
              date.season.to_s.match(/[1-4]/) ? locale["season-0#{date.season}"].to_s : date.season.to_s
            else
              case form
              when 'numeric' then date.month.to_s
              when 'numeric-leading-zeros' then "%02d" % date.month
              else
                locale["month-%02d" % date.month].to_s(attributes)
              end
            end
          when 'year'
            case form
            when 'short' then date.year.abs.to_s[-2..-1] # get the last two characters
            else # 'long'
              date.year.abs.to_s
            end
          end
      
        part = [part, locale['ad']].join if self['name'] == 'year' && date.year < 1000
        part = [part, locale['bc']].join if self['name'] == 'year' && date.year < 0
            
        part
      end
    
      format_on :process
    
    end


    # The cs:number element can be used to output any of the following
    # variables (selected with the variable attribute):
    # 
    #         "edition"
    #         "volume"
    #         "issue"
    #         "number"
    #         "number-of-volumes"
    #
    # Although these variables can also be rendered with cs:text, cs:number
    # has the benefit of offering number-specific formatting via the form
    # attribute, with values:
    # 
    # * "numeric" (default) - e.g. "1", "2", "3"
    # * "ordinal" - e.g. "1st", "2nd", "3rd"
    # * "long-ordinal" - e.g. "first", "second", "third"
    # * "roman" - e.g. "i", "ii", "iii"
    #
    # If a variable displayed with cs:number contains a mixture of numeric and
    # non-numeric text, only the first number encountered is used for
    # rendering (e.g. "12" when the entire string is "12th edition"). If a
    # variable only contains non-numeric text (e.g. "special edition"), the
    # entire string is rendered, as if cs:text were used instead. Fields can
    # be tested for containing numeric content with the is-numeric
    # conditional, e.g. "12th edition" would test "true" while "third edition"
    # would test "false" (@see Choose).
    #
    # The cs:number element may carry any of the affixes, display, formatting
    # and text-case attributes.
    #     
    class Number < Node
      attr_fields Nodes.formatting_attributes      
      attr_fields %w{ variable form }
    
      def process(data, processor=nil)
        super
      
        number = (data[variable] || self.item(data['id'])[variable] || '').to_s

        number = case form
          when 'roman'        then number.to_i.romanize
          when 'ordinal'      then locale.ordinalize(number, attributes)
          when 'long-ordinal' then locale.ordinalize(number, attributes)
          else 
            number.to_i.to_s
          end unless number.empty?
        
        number
      end

      format_on :process
    
    end

    # The cs:names element can be used to display the contents of one or more
    # name variables, each of which can contain multiple names (e.g. the
    # "author" variable will contain all the cited item's author names). The
    # variables to be displayed are set with the variable attribute. If multiple
    # variables are selected (separated by single spaces, see example below),
    # each variable is independently rendered in the order specified, with one
    # exception: if the value of variable consists of "editor" and "translator"
    # (in either order), and if the contents of the two name variables is
    # identical, then the contents of only one name variable is rendered. In
    # addition, the "editor-translator" term is used if the cs:names element
    # contains a cs:label element, replacing the default "editor" and
    # "translator" terms (e.g., this might result in "Doe (editor &
    # translator)". The delimiter attribute may be set on cs:names to delimit
    # the names of the different name variables (e.g. the semicolon in "Doe
    # (editor); Johnson (translator)").
    #
    #     <names variable="editor translator" delimiter="; ">
    #       <name/>
    #       <label prefix=" (" suffix=")"/>
    #     </names>
    #
    # There are four child elements associated with the cs:names element:
    # cs:name, cs:et-al, cs:substitute and cs:label (all discussed below). In
    # addition, the cs:names element may carry the attributes for affixes,
    # display and formatting.
    class Names < Node
      attr_fields Nodes.formatting_attributes
      attr_fields %w{ variable delimiter }
    
      attr_accessor :name, :et_al, :label, :substitute
      
      def initialize(node, style, processor=nil)
        super
      
        inherit_attributes
        
        # collect the child nodes (name, et-al, substitute, label)
        node.children.each do |node|
          name = node.name.downcase.gsub(/-/,'_') + '='
          node = Node.parse(node, style, processor)
          send(name, node)
        end
        
      end
    
      def process(data, processor=nil)
        super
      
        names = collect_names(item(data['id']))

        unless names.empty?
  
          # handle the editor-translator special case
          if names.map(&:first).sort.join.match(/editortranslator/)
            editors = names.detect { |name| name.first == 'editor' }
            translators = names.detect { |name| name.first == 'translator' }
        
            if editors == translators
              editors.first = 'editortranslator'
              names.delete(translators)
            end
          end
      
          # TODO not sure whether format is applied only once or on each name item individually

          names = names.map do |role, names|
            processed = []
            processed << self.name.process_names(role, names, @processor)
            if self.name.truncated?
              processed << ' '
              processed << (self.et_al.nil? ? locale['et-al'].to_s : self.et_al.process(data, @processor))
            end
            processed << self.label.process_names(role, names.length, @processor) unless self.label.nil?
            processed.join
          end

          names.join(delimiter)
        else
          @substitute.nil? ? '' : @substitute.process(data, processor)
        end
      end
    
      format_on :process

      private
      
      # @returns a list of all name variables covered by this node; each list
      # is wrapped in a list containing the lists role (e.g., 'editor')
      # followed by the list proper.
      def collect_names(item)
        return [] unless self.variable?
        self.variable.split(/\s+/).map { |variable| [variable, item[variable] || []] }
      end
    
      def inherit_attributes
        inherit_attributes_from(['citation', 'bibliography', 'style'], ['delimiter'], 'names-')
      end
      
    end
  
    # The cs:name element is a required child element of cs:names, and describes
    # both how individual names are formatted, and how names within a name
    # variable are separated from each other. The attributes that may be used on
    # cs:name are:
    #
    # 'and'
    # This attribute specifies the delimiter between the second to last
    # and the last name of the names in a name variable. The value of the
    # attribute may be either "text", which selects the "and" term, or "symbol",
    # which selects the ampersand (&).
    #
    # 'delimiter'  
    # Specifies the text string to separate names of a name variable. The
    # default value is ", " ("J. Doe, S. Smith").
    #
    # 'delimiter-precedes-last'
    # Determines in which cases the delimiter used to delimit names is also used
    # to separate the second to last and the last name in name lists. The
    # possible values are:
    #
    #   "contextual" (default): the delimiter is only included for name lists with three or more names
    #       2 names: "J. Doe and T. Williams,"
    #       3 names: "J. Doe, S. Smith, and T. Williams"
    #   "always": the delimiter is always included
    #       2 names: "J. Doe, and T. Williams"
    #       3 names: "J. Doe, S. Smith, and T. Williams"
    #   "never": the delimiter is never included
    #       2 names: "J. Doe and T. Williams,"
    #       3 names: "J. Doe, S. Smith and T. Williams"
    # 
    # 'et-al-min / et-al-use-first'  
    # Together, these attributes control et-al abbreviation. When the number of
    # names in a name variable matches or exceeds the number set on et-al-min,
    # the rendered name list is truncated at the number of names set on
    # et-al-use-first. If truncation occurs, the "et-al" term is appended to the
    # names rendered (see also Et-al). With a single name (et-al-use-first="1"),
    # the "et-al" term is preceded by a space (e.g. "Doe et al."). With multiple
    # names, the "et-al" term is preceded by the name delimiter (e.g. "Doe,
    # Smith, et al.").
    #
    # 'et-al-subsequent-min / et-al-subsequent-use-first'  
    # The (optional) et-al-min and et-al-use-first attributes take effect for
    # all cites and bibliographic entries. With the et-al-subsequent-min and
    # et-al-subsequent-use-first attributes divergent et-al abbreviation rules
    # can be specified for subsequent cites (cites referencing earlier cited
    # items).
    #
    # The remaining attributes, discussed below, only affect personal names.
    # Personal names require a "family" name-part, and may also contain "given",
    # "suffix", "non-dropping-particle" and "dropping-particle" name-parts. The
    # roles of these name-parts, which are delimited by single spaces in
    # rendered names, are:
    #
    # * "family": the surname minus any particles and suffixes
    # * "given": the given names, which may be either full ("John Edward") or
    #   initialized ("J. E.")
    # * "suffix": name suffix, e.g. "Jr." in "John Smith Jr." and "III" in "Bill
    #   Gates III"
    # * "non-dropping-particle": name particles that are not dropped when only the
    #   last name is shown ("de" in the Dutch surname "de Koning") but which may
    #   be treated as a separate object from the family name (e.g. for sorting)
    # * "dropping-particle": name particles that are dropped when only the
    #   surname is shown ("van" in "Ludwig van Beethoven", which becomes
    #   "Beethoven")
    #
    # 'form'  
    # Specifies whether all the name-parts of personal names should be displayed
    # (value "long"), or only the family name and the non-dropping-particle
    # (value "short"). A third value, "count", returns the total number of names
    # that would be otherwise displayed by the use of the cs:names element
    # (taking into account the effects of et-al abbreviation and
    # editor/translator collapsing), and may be used for advanced sorting.
    #
    # 'initialize-with'  
    # If this attribute is set, given names are converted to initials. The
    # attribute value specifies the suffix that is included after each initial
    # ("." results in "J.J. Doe"). Note that the global initialize-with-hyphen
    # option controls how compound given names (e.g. "Jean-Luc") are hyphenated
    # when initialized (see Hyphenation of Initialized Names).
    #
    # 'name-as-sort-order'
    # Specifies that names should be displayed with the given name following the
    # family name (e.g. "John Doe" becomes "Doe, John"). The attribute may have
    # one of the two values:
    #
    # "first": name-as-sort-order applies to the first name in each name variable
    # "all": name-as-sort-order applies to all names
    #
    # Note that the sort order of names may differ from the display order for
    # names containing particles and suffixes (see Name-part order). Also, this
    # attribute only affects names written in the latin or Cyrillic alphabet.
    # Names written in other alphabets (e.g. Asian scripts) are always shown
    # with the family name preceding the given name.
    #
    # 'sort-separator'  
    # Sets the delimiter for name-parts that have switched positions as a result
    # of name-as-sort-order. The default value is ", " ("Doe, John"). As is the
    # case for name-as-sort-order, this attribute only affects names written in
    # the latin or Cyrillic alphabet.
    #
    # The cs:name element may also carry any of the attributes for affixes and formatting.
    #
    class Name < Node
      attr_fields Nodes.formatting_attributes
      attr_fields Nodes.inheritable_name_attributes
      attr_fields %w{ form delimiter }
        
      def initialize(node, style, processor=nil)
        super
        inherit_attributes
        attributes['delimiter'] ||= ', '
        attributes['delimiter-precedes-last'] ||= 'true'
        node.children.each do |node|
          names = [node['name']]
          names << 'dropping-particle' << 'non-dropping-particle' if names.first == 'family'
          names.each { |name| self.parts[name] = Node.parse(node, style, processor) }
        end
      end
    
      def parts
        @parts ||= {}
      end
  
      def truncated?
        @truncated || false
      end
            
      def process_names(role, names, processor=nil)
        self.processor = processor unless processor.nil?

        # truncate names
        if et_al_min? && names.length <= et_al_min.to_i
          names = names[0, et_al_use_first.to_i]
          @truncated = true
        else
          @truncated = false
        end

        # set display options
        names = names.each { |name| name.options = attributes }
        names.first.options['name-as-sort-order'] = 'true' if name_as_sort_order == 'first'

        # name-part formatting
        names.map! { |name| name.display({}, self.parts) }
        
        # join names
        if names.length > 2
          names = [names[0..-2].join(delimiter), names.last]
        end

        names.join(ampersand)
      end

      format_on :process_names

      private      

      # @returns the delimiter to be used between the penultimate and last
      # name in the list.
      def ampersand
        if self.and?
          ampersand = self.and == 'symbol' ? '&' : locale[self.and == 'text' ? 'and' : self.and].to_s(attributes)
          ampersand = delimiter_precedes_last? ? [delimiter, ampersand].join : ampersand
          ampersand.center(ampersand.length + 2)
        else
          delimiter_precedes_last? ? delimiter : ' '
        end
      end

      def inherit_attributes
        inherit_attributes_from(['citation', 'bibliography', 'style'], Nodes.inheritable_name_attributes)
        inherit_attributes_from(['citation', 'bibliography', 'style'], ['form', 'delimiter'], 'name-')
      end
      
    end

    # The cs:name element may include one or two cs:name-part child elements.
    # These child elements accept the formatting and text-case attributes, which
    # allows for separate formatting of the different name parts (e.g. "Jane
    # DOE", see example below). The required name attribute on cs:name-part
    # specifies which name-parts are affected: when set to "given", the
    # formatting only acts on the "given" name-part. When set to "family", the
    # formatting acts on the "family", "dropping-particle" and
    # "non-dropping-particle" name-parts (the "suffix" name-part is not subject
    # to any name-part formatting). The order of the cs:name-part elements does
    # not affect which, and in what order, the name-parts are rendered.
    #
    #     <names variable="author">
    #       <name>
    #         <name-part name="family" text-case="uppercase">
    #       </name>
    #     </names>
    #
    class NamePart < Node
      attr_fields Nodes.formatting_attributes
      attr_fields %w{ name }
    end
  
    # Et-al abbreviation, controlled via the et-al attributes on cs:name (see
    # Name), can be further customized with the optional cs:et-al element, which
    # should be included directly after the cs:name element. The term attribute
    # of this element can be set to either "et-al" (default) or to "and others"
    # to use either term (with this different et-al terms can be used for
    # citations and the bibliography). In addition, attributes for affixes and
    # formatting can be used, for example to italicize the et-al term:
    #
    #     <names variable="author">
    #       <name/>
    #       <et-al term="and others" font-style="italic"/>
    #     </names>
    #
    class EtAl < Node
      attr_fields Nodes.formatting_attributes
      attr_fields %w{ term }
    
      attr_accessor :parent

      def process(data, processor=nil)
        super
        locale[term].to_s(attributes)
      end
    
      format_on :process
    
    end
  
    # The optional cs:substitute element, which should be included as the last
    # child element of cs:names, controls substitution in case the name
    # variables specified in the parent cs:names element are empty. The
    # substitutions are specified as child elements of cs:substitute, and can
    # consist of any of the standard rendering elements (with the exception of
    # cs:layout). It is also possible to use a shorthand version of cs:names,
    # which doesn't allow for any child elements, and uses the attributes values
    # set on the cs:name and cs:et-al child elements of the original cs:names
    # element. If cs:substitute contains multiple child elements, the first
    # element to return a non-empty result is used for substitution. Substituted
    # variables are repressed in the rest of the output to prevent duplication.
    # An example, where an empty "author" name variable is substituted by the
    # "editor" name variable, or, when no editors exist, by the "title" macro:
    #
    #     <macro name="author">
    #       <names variable="author">
    #         <name/>
    #         <substitute>
    #           <names variable="editor"/>
    #           <text macro="title"/>
    #         </substitute>
    #       </names>
    #     </macro>
    #
    class Substitute < Node
    
      attr_accessor :parent
    
      def initialize(node, style, processor=nil)
        super
        node.children.each { |node| self.elements.push(Node.parse(node, style, processor)) }
      end
    
      def elements
        @elements ||= []
      end
      
      def process(data, processor=nil)
        super
        
        elements.each do |element|
          processed = element.process(data, processor)
          return processed unless processed.empty?
        end
        
        ''
      end
    
    end
  
    # The cs:label element, used to output text terms whose pluralization
    # depends on the contents of another variable (e.g. "(editors)" in "Doe and
    # Smith (editors)"), is discussed in detail in the label section. It should
    # be included after the cs:name and cs:et-al elements, but before the
    # cs:substitute element. When used within cs:names, the variable attribute
    # should be omitted, as the value set on the parent cs:names element is
    # used.
    #
    # The Citation Style Language includes several variables that have
    # matching terms. The cs:label element can be used to render one of these
    # terms, while matching the term plurality with that of the corresponding
    # variable. The variable/term combination is selected with the variable
    # attribute, which can be set to either "page" or "locator". When cs:label
    # is used as a child element of cs:names, the value of the variable
    # attribute is automatically inherited from the parent cs:names element.
    # The example below displays the "page" variable, using the singular form
    # of the "page" term for a single page ("page 5"), or the plural form for
    # a page range ("pages 5-7").  
    #  
    class Label < Node
      attr_fields Nodes.formatting_attributes      
      attr_fields %w{ variable plural form }
    
      def process(data, processor=nil)
        super
        locale[data['label']].to_s(attributes.merge({ 'plural' =>  is_plural?(data, 0) ? 'true' : 'false' }))
      end
    
      def process_names(role, number, processor=nil)
        self.processor = processor unless processor.nil?
        locale[role].to_s(attributes.merge({ 'plural' => is_plural?(nil, number) ? 'true' : 'false' }))        
      end
        
      format_on :process
      format_on :process_names
      
      def is_plural?(data, number)
        case
        when plural == 'always'
          true
        when plural == 'never'
          false
        when number > 1
          true
        when ['locator', 'page'].include?(variable)
          data[variable].to_s.match(/\d+f|\d+\-\d+/)
        else
          false
        end
      end
    end

    # The cs:group element may contain one or more rendering elements (not
    # cs:layout). cs:group itself may carry the delimiter attribute (to
    # delimit the enclosed elements) and the attributes for affixes (applied
    # to the group output as a whole), display and formatting (formatting
    # settings are transmitted to the enclosed elements). Note that cs:group
    # implicitly acts as a conditional: cs:group and its child elements are
    # suppressed if a) at least one rendering element in cs:group calls a
    # variable (either directly or via a macro), and b) all variables that are
    # called are empty. This behavior exists to accommodate descriptive
    # cs:text elements. For example
    #
    #     <layout>
    #       <group prefix="(" suffix=")">
    #         <text value="Published by: "/>
    #         <text variable="publisher"/>
    #       </group>
    #     </layout>
    #
    # results in "(Published by: Company A)" when the "publisher" variable is
    # set to "Company A", but doesn't generate output when the "publisher"
    # variable is empty.
    #
    class Group < Node
      attr_fields Nodes.formatting_attributes
      attr_fields %w{ delimiter }    

      def initialize(node, style, processor=nil)
        super
        
        collect_formatting_attributes(%w{ delimiter suffix prefix })
        
        @node.children.each do |node|
          node = Node.parse(node, style, processor)
          
          # push down formatting attributes
          apply_formatting_attributes(node)
          
          self.elements.push(node)
        end
      end

      def elements
        @elements ||= []
      end

      def process(data, processor=nil)
        super
        processed = @elements.map { |element| element.process(data, processor) }
        processed.include?('') ? '' : apply_format(processed.join(delimiter))
      end

      
      protected
      
      def collect_formatting_attributes(exceptions=[])
        @formatting_attributes = {}
        (Nodes.formatting_attributes - exceptions).each do |key|
          @formatting_attributes[key] = self[key]
          self.attributes.delete(key)
        end
        @formatting_attributes
      end
      
      def apply_formatting_attributes(node)
        @formatting_attributes.each_pair do |key, value|
          node[key] ||= value
        end
      end
      
    end

    # Similarly to the conditional statements encountered in programming
    # languages, the cs:choose element allows for the conditional rendering of
    # rendering elements. An example is shown below:
    #
    #     <choose>
    #       <if type="book thesis" match="any">
    #         <text variable="title" font-style="italic">
    #       </if>
    #       <else-if type="chapter">
    #         <text variable="title" quotes="true">
    #       </else-if>
    #       <else>
    #         <text variable="title">
    #       </else>
    #     </choose>
    #
    # cs:choose requires a cs:if child element, which may be followed by one or
    # more cs:else-if child elements, and an optional closing cs:else child
    # element. The cs:if and cs:else-if elements may contain any number of
    # rendering elements (except for cs:layout). As an empty cs:else element
    # would be superfluous, cs:else must contain at least one rendering element.
    # cs:if and cs:else-if elements must each hold at least one condition, which
    # are expressed as attributes. The different types of conditions available
    # are:
    #
    # disambiguate  
    # The contents of an <if disambiguate="true"> block is only rendered if it
    # disambiguates two otherwise identical citations. This attempt at
    # disambiguation will only be made when all other disambiguation methods
    # have failed to uniquely identify the target source.
    #
    # is-numeric
    # Tests whether the given variables (Appendix I - Variables) contain numeric
    # data.
    #
    # is-uncertain-date  
    # Tests whether the given date variables contain uncertain dates.
    #
    # locator  
    # Tests whether the locator matches the given locator variable subtype (see
    # Locators).
    #
    # position
    # Tests whether the position of the item cite matches the given positions
    # (when called within cs:bibliography, this condition will always test
    # "false"). The different positions are (note on terminology: a citation
    # refers to a citation group, which contains one or more cites to individual
    # items):
    #
    # * "first": the position of a cite that is the first to reference an item
    # * "ibid"/"ibid-with-locator"/"subsequent": a cite that references an
    #   earlier cited item always has the "subsequent" position. In special
    #   cases cites may have the "ibid" or "ibid-with-locator" position. These
    #   positions are only assigned when:
    #
    #   1. the current cite immediately follows on another cite, within the same
    #      citation, that references the same item
    #
    #      or
    #
    #   2. the current cite is the first cite in the citation, and the previous
    #      citation includes a single cite that references the same item
    #
    #
    #   If either requirement is met, the presence of locators determines which
    #   position is assigned:
    #
    #   1. Preceding cite does not have a locator: if the current cite has a
    #      locator, the position of the current cite is "ibid-with-locator".
    #      Otherwise the position is "ibid".
    #
    #   2. Preceding cite does have a locator: if the current cite has the same
    #      locator, the position of the current cite is "ibid". If the locator
    #      differs the position is "ibid-with-locator". If the current cite
    #      lacks a locator the position is "subsequent".
    #
    # * "near-note": the position of a cite following another cite that
    #   references the same item. Both cites have to be located in foot or
    #   endnotes, and the distance between both cites may not exceed the maximum
    #   distance (measured in number of foot or endnotes) set with the
    #   near-note-distance option (see Note Distance).
    #
    # Note that each cite can have multiple position values. Whenever
    # position="ibid-with-locator" is true, position="ibid" is also true.
    # And whenever position="ibid" or position="near-note" is true,
    # position="subsequent" is also true.
    #
    # type
    # Tests whether the item matches the given types (Appendix II - Types).
    #
    # variable
    # Tests whether the given variables (Appendix I - Variables) contain
    # non-empty values.
    #
    # With the exception of disambiguate, all conditions allow for multiple test
    # values (separated with spaces, e.g. "book thesis").
    #
    # The cs:if and cs:else-if elements may include the match attribute to
    # control the testing logic, with possible values:
    #
    # * "all" (default): the element only tests "true" when all conditions test "true" for all given test values
    # * "any": the element tests "true" when any condition tests "true" for any given test value
    # * "none": the element only tests "true" when none of the conditions test "true" for any given test value
    #
    class Choose < Node

      def initialize(node, style, processor=nil)
        super
        @node.children.each { |node| self.elements.push(ConditionalBlock.new(node, style, @processor)) }
      end
    
      def elements
        @elements ||= []
      end
      
      def process(data, processor=nil)
        super
        
        elements.each do |element|
          return element.process(data, processor) if element.evaluate?(item(data['id']))
        end

        ''
      end
      
    end
  
    class ConditionalBlock < Node
      attr_fields %w{ disambiguate is-numeric is-uncertain-date locator
        position type variable match }
      
      attr_reader :name
      
      def initialize(node, style, processor=nil)
        super
        @name = @node.name
        @node.children.each { |node| self.elements.push(Node.parse(node, style, @processor)) }
      end
      
      def elements
        @elements ||= []
      end
      
      def process(data, processor=nil)
        super
        self.elements.map { |element| element.process(data, @processor) }.join
      end
      
      def evaluate?(item)
        case
        when self.disambiguate?
          false
        when self.is_numeric?
          false
        when self.is_uncertain_date?
          false
        when self.locator?
          false
        when self.position?
          false
        when type?
          self.is_match?(item['type'].to_s, type.split(/\s+/))
        when self.variable?
          self.is_empty?(item, variable.split(/\s+/))
        when @name == 'else'
          true
        else
          false
        end
      end
      
      # does a match any/all/none b in bs?
      def is_match?(a, bs)
        m = bs.map { |b| a == b }.inject { |a, b| self.match == 'any' ? a || b : a && b }
        self.match == 'none' ? !m : m
      end
      
      # is any/all/none v in vs non-empty?
      def is_empty?(item, vs)
        m = vs.map { |v| !item[v].nil? }.inject { |a, b| self.match == 'any' ? a || b : a && b }
        self.match == 'none' ? !m : m
      end
    end

  end
end