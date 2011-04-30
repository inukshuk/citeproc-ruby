module CSL

  class Nodes

    @formatting_attributes = %w{ text-case font-style font-variant font-weight
      text-decoration vertical-align prefix suffix display strip-periods  }

    @inheritable_name_attributes = %w{ and delimiter-precedes-last et-al-min
      et-al-use-first et-al-subsequent-min et-al-subsequent-use-first
      initialize-with name-as-sort-order sort-separator }
  
    class << self
      attr_reader :formatting_attributes, :inheritable_name_attributes
    
      # Parses the given node an returns a new instance of Node or a suitable
      # subclass corresponding to the node's name.
      def parse(*args, &block)
        node = args.detect { |argument| argument.is_a?(Nokogiri::XML::Node) }
        raise(ArgumentError, "arguments must contain an XML node; was #{ args.map(&:class).inspect }") if node.nil?
        
        name = node.name.split(/[\s-]+/).map(&:capitalize).join
        klass = Nodes.const_defined?(name) ? Nodes.const_get(name) : Node
        
        klass.new(*args, &block)
      end
    end
    
    
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
      include Support::Attributes
      include Support::Tree

      attr_reader :style

      class << self
        # Chains the format method to the given methods
        def format_on(*args)
          args.flatten.each do |method_id|

            # Set up Around Alias Chain
            original_method = [method_id, 'without_formatting'].join('_')
            alias_method original_method, method_id

            define_method method_id do |*args, &block|
              begin
                string = send(original_method, *args, &block)
                processor = args.detect { |argument| argument.is_a?(CiteProc::Processor) }
                
                processor.nil? ? string : processor.format(string, attributes)
              rescue Exception => e
                CiteProc.log :error, "failed to format string #{ string.inspect }", e
                args[0]
              end
            end
          end
        end
      end

      def initialize(*args)
        @style = args.detect { |argument| argument.is_a?(Style) }
        args.delete(@style) unless @style.nil?
        
        args.each do |argument|
          case          
          when argument.is_a?(Node)
            @parent = argument
            @style = @parent.style || @style
            
          when argument.is_a?(String) && argument.match(/^\s*</)
            parse(Nokogiri::XML.parse(argument) { |config| config.strict.noblanks }.root)
          
          when argument.is_a?(Nokogiri::XML::Node)
            parse(argument)
          
          when argument.is_a?(Hash)
            merge!(argument)
          
          else
            CiteProc.log.warn "cannot initialize Node from argument #{ argument.inspect }" unless argument.nil?
          end
        end

        set_defaults
        
        yield self if block_given?
      end

      # Parses the given XML node.
      def parse(node)
        return if node.nil?
        
        node.attributes.values.each { |a| attributes[a.name] = a.value }
        
        @children = node.children.map do |child|
          Nodes.parse(self, child)
        end
        
        inherit_attributes(node)
        self
      end
      
      # @returns a new Node with the attributes and style of self and other
      # merged.
      def merge(other)
        return self.copy if other.nil?
        self.class.new(attributes.merge(other.attributes), other.style || style)
      end

      # @returns a new Node that contains the same attributes and style as self.
      def copy; self.class.new(attributes, style); end
      
      # @returns a new Node with the attributes of self and other merged;
      # attributes in other take precedence.      
      def reverse_merge(other)
        other.merge(self)
      end
      
      # @returns the localized term with the given key.
      def localized_terms(key, processor=nil)
        localize(:term, key, processor) do |hash|
          return hash[key] if hash.has_key?(key) && !hash[key].empty?
        end        
      end

      # @returns the localized date parts.
      def localized_date_parts(key, processor=nil)
        localize(:date, key, processor) do |hash|
          return hash[key] if hash.has_key?(key) && !hash[key].empty?
        end
      end
      
      def localized_options(key, processor=nil)
        localize(:options, key, processor) do |hash|
          return hash[key] if hash.has_key?(key)
        end
      end
      
      # Processes the supplied data. @returns a formatted string.
      def process(data, processor)
        ''
      end
        
      def to_s
        attributes.merge('node' => self.class.name).inspect
      end

      protected

      # Empty method; nodes may override this method.
      def set_defaults
      end
      
      # TODO Refactor: move all processor-dependencies to citeproc
      
      # Prioritized locale look-up.
      def localize(type, key, processor, &block)
        unless @style.nil?
          style.locales(processor && processor.language || nil).each do |locale|
            yield locale.send(type)
          end
        end 
        
        unless processor.nil?
          yield processor.locale.send(type) 
          yield CSL::Locale.new(processor.language)
        end
        
        CSL.default_locale.send(type)[key]
      end

      # @returns the locale with the highest priority
      def locale(processor = nil)
        locales(processor).first
      end
      
      def locales(processor = nil)
        if processor.nil?
          style && style.locales || []
        else
          (style && style.locales(processor.language, processor.region) || []) + [Locale.new(processor.language)]
        end  + [Locale.default]
      end

      
      # Empty method; nodes may override this method.
      def inherit_attributes(node)
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
      def inherit_attributes_from(node, nodes=[], attributes=[], prefix='')
        return unless node
        
        # TODO refactor so that node is not required anymore
        parent = node.parent        
        until parent.name == 'document' do
          attributes.each { |attribute| self[attribute] ||= parent[[prefix, attribute].join] } if nodes.include?(parent.name)
          parent = parent.parent
        end
      end
      
      def handle_processing_error(e, data, processor)
        CiteProc.log :error, "failed to process item #{ data.inspect }", e
        ''
      end
    end

    
    # All the rendering elements that should appear in the citations and
    # bibliography should be nested inside the cs:layout element. Itself a
    # rendering element, cs:layout accepts both affixes and formatting
    # attributes. When used in the cs:citation element, a delimiter can be set
    # to separate multiple bibliographic items in a single citation.
    class Layout < Node
      attr_fields Nodes.formatting_attributes
      attr_fields %w{ delimiter }
    
      def process(data, processor)
        children.map { |child| child.process(data, processor) }.join
      rescue Exception => e
        handle_processing_error(e, data, processor)
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
    
      def process(data, processor)
        case
        when has_value?
          text = value
          
        when has_macro?
          text = @style.macros[macro].process(data, processor) 
          
        when has_term?
          text = localized_terms(term).to_s(attributes)
          
        when has_variable?
          text = (data["short#{variable.capitalize}"] || data[['short', variable].join('-')] || data[variable]).to_s

          if form == 'short'
            text = processor.abbreviate(variable, text)
          end
          
          if variable == 'page' && @style.options.has_key?('page-range-format')
            text = format_page_range(text, @style.options['page-range-format'])
          end
          
          if variable == 'page-first' && text.empty?
            text = data['page'].to_s.scan(/\d+/).first.to_s
          end
          
        else
          text = ''
        end
        
        # Add localized quotes
        if has_quotes? && !text.empty?
          prefix = [self['prefix'], localized_terms('open-quote')].compact.join
          
          if localized_options('punctuation-in-quote', processor) == 'true'
            suffix = self['suffix'].to_s.sub(/^([\.,!?;:]+)/, '')
            suffix = [$1, localized_terms('close-quote'), suffix].compact.join
          else
            text = text.sub(/([\.,!?;:]+)$/, '')
            suffix = [localized_terms('close-quote'), $1, self['suffix']].compact.join
          end
          
          self['prefix'] = prefix
          self['suffix'] = suffix
        end
      
        text
      rescue Exception => e
        handle_processing_error(e, data, processor)      
      end
  
      format_on :process
      
      protected
      
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


    #
    # The Date element is used to output dates, in either a localized or a
    # non-localized format. The desired date variable (@see CiteProc::Date) is
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
    #
    class Date < Node
      attr_fields Nodes.formatting_attributes
      attr_fields %w{ variable form date-parts delimiter }
      
      def process(data, processor)
        date = data[variable]

        case
        when date.nil?
          ''
        when date.literal?
          date.literal
        when date.range?
          process_range(date, processor)
        else
          parts(processor).map { |part| part.process(date, processor) }.join(delimiter)
        end
      rescue Exception => e
        handle_processing_error(e, data, processor)
      end

      format_on :process
      
      # By default, date ranges are delimited by an en-dash (e.g. "May-July
      # 2008"). The range-delimiter attribute can be used to specify custom
      # date range delimiters. The attribute value set on the largest
      # date-part ("day", "month" or "year") that differs between the two
      # dates of the date range will then be used instead of the en-dash. For
      # example,
      #
      # <style>
      #   <citation>
      #     <layout>
      #       <date variable="issued">
      #         <date-part name="month" suffix=" "/>
      #         <date-part name="year" range-delimiter="/"/>
      #       </date>
      #     </layout>
      #   </citation>
      # </style>
      # 
      # would result in "May-July 2008" and "May 2008/June 2009".
      #
      def process_range(date, processor)
        order = parts(processor)

        parts = [order, order].zip(date.display_parts).map do |order, parts|
          order.map { |part| parts.include?(part['name']) ? part : nil }.compact
        end

        result = parts.zip([date, date.to]).map { |parts, date| parts.map { |part| part.process(date, processor) }.join(delimiter) }.compact
        result[0].gsub!(/\s+$/, '')
        result.join(parts[0].last.range_delimiter)

        # case
        # when date.open_range?
        #   result << parts.map { |part| part.process(date, processor) }.join(delimiter)
        #   result << parts.last.range_delimiter
        #   
        # when discriminator == 'month'
        #   month_parts = parts.reject { |part| part['name'] == 'year' }
        # 
        #   result << month_parts.map { |part| part.process(date, processor) }.join(delimiter)
        #   result << month_parts.last.range_delimiter
        #   result << parts.map { |part| part.process(date.to, processor) }.join(delimiter)
        # 
        # when discriminator == 'day'
        #   day_parts = parts.select { |part| part['name'] == 'day' }
        # 
        #   result << day_parts.map { |part| part.process(date, processor) }.join(delimiter)
        #   result << day_parts.last.range_delimiter
        #   result << parts.map { |part| part.process(date.to, processor) }.join(delimiter)
        #   
        # else # year
        #   year_parts = parts.select { |part| part['name'] == 'year' }
        # 
        #   result << parts.map { |part| part.process(date, processor) }.join(delimiter)
        #   result << year_parts.last.range_delimiter
        #   result << year_parts.map { |part| part.process(date.to, processor) }.join(delimiter)
        #   
        # end
        # 
        # result.join
      end
      
      def parts(processor)
        has_form? ? merge_parts(localized_date_parts(form, processor), children) : children
      end
      
      
      # Combines two lists of date-part elements; includes only the parts set
      # in the 'date-parts' attribute and retains the order of elements in the
      # first list.
      def merge_parts(p1, p2)
        merged = p1.map do |part|
          DatePart.new(part.attributes, style).merge(p2.detect { |p| p['name'] == part['name'] })
        end
        merged.reject { |part| !date_parts.match(Regexp.new(part['name'])) }
      end

      def date_parts
        self['date-parts'] || 'year-month-day'
      end
    end

    class DatePart < Node
      attr_fields Nodes.formatting_attributes
      attr_fields %w{ name form range-delimiter strip-periods }
    
      def process(date, processor)  
        send(['process', self['name']].join('_'), date, processor)
      rescue Exception => e
        handle_processing_error(e, data, processor)      
      end
    
      format_on :process

      def process_year(date, processor)
        return '' if date.year.nil?
        
        year = date.year.abs.to_s
        year = year[-2..-1] if form == 'short'
        year = [year, localized_terms('ad')].join if date.ad?
        year = [year, localized_terms('bc')].join if date.bc?
        year
      end
      
      def process_month(date, processor)
        return process_season(date, processor) if date.has_season?
        return '' if date.month.nil?      

        case
        when form == 'numeric'
          date.month.to_s
        when form == 'numeric-leading-zeros'
          "%02d" % date.month
        else
          localized_terms("month-%02d" % date.month, processor).to_s(attributes)
        end      
      end
      
      def process_season(date, processor)
        season = date.season.to_s
        season = date.month.to_s if season.match(/true|always|yes/i)
        season = localized_terms('season-%02d' % season.to_i, processor).to_s if season.match(/0?[1-4]/)
        season
      end

      def process_day(date, processor)
        return '' if date.day.nil?
        
        case
        when form == 'ordinal'
          locale(processor).ordinalize(date.day, 'gender-form' => gender(date, processor))
        when form == 'numeric-leading-zeros'
          "%02d" % date.day
        else # 'numeric'
          date.day.to_s
        end
      end
      
      def gender(date, processor)
        localized_terms("month-%02d" % date.month, processor).gender
      end
    
      protected
      
      def set_defaults
        self['range-delimiter'] ||= "\u2013"
      end
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
    
      def process(data, processor)
        number = data[variable]
   
        term = localized_terms(variable)
        attributes['gender-form'] = term.gender if term.has_gender?
        
        case
        when number.nil? || number.empty? || !number.numeric?
          number.to_s
        when form == 'roman'
          number.to_i.romanize
        when form == 'ordinal'
          locale(processor).ordinalize(number.to_i, attributes)
        when form == 'long-ordinal'
          locale(processor).ordinalize(number.to_i, attributes)
        else
          number.to_i.to_s
        end
      rescue Exception => e
        handle_processing_error(e, data, processor)      
      end

      format_on :process
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
      attr_fields %w{ form delimiter delimiter-precedes-et-al }

      def parts
        @parts ||= Hash.new { |h, k| k.match(/(non-)?dropping-particle/) ? h['family'] : {} }
      end
  
      def process_names(role, names, processor)

        # set display options
        names = names.each { |name| name.merge_options(attributes) }
        names.first.options['name-as-sort-order'] = 'true' if name_as_sort_order == 'first'

        # name-part formatting
        names.map! do |name|
          name.normalize(name.display_order.map do |token|
            processor.format(name.send(token.tr('-', '_')), parts[token])
          end.compact.join(name.delimiter))
        end        

        # join names
        if names.length > 2
          names = [names[0..-2].join(delimiter), names.last]
        end

        names.join(ampersand(processor))
      rescue Exception => e
        CiteProc.log :error, "failed to process names #{ names.inspect }", e
      end

      format_on :process_names

      def truncate(names)
        # TODO subsequent
        et_al_min? && et_al_min.to_i <= names.length ? names[0, et_al_use_first.to_i] : names
      end
      
      protected
      
      def set_defaults
        attributes['delimiter'] ||= ', '
        attributes['delimiter-precedes-last'] ||= 'false'
        attributes['et-al-use-first']  ||= '1'
        
        children.each { |child| parts[child['name']] = child.attributes }        
      end      

      # @returns the delimiter to be used between the penultimate and last
      # name in the list.
      def ampersand(processor)
        if self.and?
          ampersand = self.and == 'symbol' ? '&' : localized_terms(self.and == 'text' ? 'and' : self.and).to_s(attributes)
          delimiter_precedes_last? ? [delimiter, ampersand, ' '].join : ampersand.center(ampersand.length + 2)
        else
          delimiter
        end
      end

      def inherit_attributes(node)
        inherit_attributes_from(node, ['citation', 'bibliography', 'style'], Nodes.inheritable_name_attributes)
        inherit_attributes_from(node, ['citation', 'bibliography', 'style'], ['et-al-use-first', 'delimiter-precedes-et-al'])
        inherit_attributes_from(node, ['citation', 'bibliography', 'style'], ['form', 'delimiter'], 'name-')
        inherit_attributes_from(node, ['style'], ['demote-non-dropping-particle', 'initialize-with-hyphen'])
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

      def process(data, processor)
        super
        localized_terms(term ||  'et-al').to_s(attributes)
      rescue Exception => e
        handle_processing_error(e, data, processor)        
      end
    
      format_on :process
    
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
    
      def process(data, processor)
        localized_terms(data['label'].to_s).to_s(attributes.merge({ 'plural' =>  plural?(data, 0).to_s }))
      rescue Exception => e
        handle_processing_error(e, data, processor)        
      end
    
      def process_names(role, number, processor)
        localized_terms(role).to_s(attributes.merge({ 'plural' => plural?(nil, number).to_s }))        
      rescue Exception => e
        handle_processing_error(e, data, processor)        
      end
        
      format_on :process
      format_on :process_names
      
      def plural?(data, number)
        case
        when plural == 'always'
          true
        when plural == 'never'
          false
        when number > 1
          true
        when ['locator'].include?(variable)
          data[variable].to_s.match(/\d+f|\d+\-\d+/)
        else
          false
        end
      end
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
        
      def process(data, processor)
        super
        children.each do |child|
          processed = child.process(data, processor)
          return processed unless processed.empty?
        end
        ''
      rescue Exception => e
        handle_processing_error(e, data, processor)        
      end
    
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
    #
    class Names < Node
      attr_fields Nodes.formatting_attributes
      attr_fields %w{ variable delimiter }
    
      [:name, :et_al, :label, :substitute].each do |method_id|
        klass = CSL::Nodes.const_get(method_id.to_s.split(/_/).map(&:capitalize).join)
        define_method method_id do
          elements = children.empty? && parent.is_a?(Substitute) && klass != Substitute ? parent.parent.children : children
          elements.detect { |child| child.class == klass }
        end
      end
         
      def prefix_label?
        children.map {|c| [Label, Name].include?(c.class) ? c.class : nil }.compact == [Label, Name]
      end
         
      def process(data, processor)
        names = collect_names(data)
        
        count_only = self.name.form == 'count'
        
        unless names.empty? || names.map(&:last).flatten.empty?
  
          # handle the editor-translator special case
          if names.map(&:first).sort.join.match(/editortranslator/)
            editors = names.detect { |name| name.first == 'editor' }
            translators = names.detect { |name| name.first == 'translator' }
        
            if editors.last.sort == translators.last.sort
              editors[0] = 'editortranslator'
              names.delete(translators)
            end
          end
      
          names = names.map do |role, names|
            processed = []
            
            truncated = name.truncate(names)

            unless count_only
              processed << name.process_names(role, truncated, processor)
            
              if names.length > truncated.length
                # use delimiter before et al. if there is more than a single name; squeeze whitespace
                others = (et_al.nil? ? localized_terms('et-al').to_s : et_al.process(data, processor))
                link = (name.et_al_use_first.to_i > 1 || name.delimiter_precedes_et_al? ? name.delimiter : ' ')

                processed << [link, others].join.squeeze(' ')
              end
            
              processed.send(prefix_label? ? :unshift : :push, label.process_names(role, names.length, processor)) unless label.nil?
            else
              processed << truncated.length
            end

            processed.join
          end
          
          count_only ? names.inject(0) { |a, b| a.to_i + b.to_i }.to_s : names.join(delimiter)
        else
          count_only ? '0' : substitute.nil? ? '' : substitute.process(data, processor)
        end
      rescue Exception => e
        handle_processing_error(e, data, processor)        
      end
    
      format_on :process

      protected
      
      # @returns a list of all name variables covered by this node; each list
      # is wrapped in a list containing the lists role (e.g., 'editor')
      # followed by the list proper.
      def collect_names(item)
        return [] unless self.variable?
        self.variable.split(/\s+/).map { |variable| [variable, (item[variable] || []).map(&:clone)] }
      end
    
      def inherit_attributes(node)
        inherit_attributes_from(node, ['citation', 'bibliography', 'style'], ['delimiter'], 'names-')
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

      def process(data, processor)
        start_observing(data)

        processed = children.map { |child| child.process(data, processor) }.reject(&:empty?).join(delimiter)

        stop_observing(data)

        # if any variable returned nil, skip the entire group
        skip? ? '' : processor.format(processed, attributes)
      rescue Exception => e
        handle_processing_error(e, data, processor)        
      end

      def start_observing(item)
        @variables = []
        item.add_observer(self)
      end
      
      def stop_observing(item)
        item.delete_observer(self)
      end
      
      def update(key, value)
        @variables << [key, value]
      end

      def skip?
        @variables && @variables.map(&:last).all?(&:nil?)
      end
      
      
      protected

      def set_defaults
        formatting_attributes = collect_formatting_attributes(%w{ delimiter suffix prefix })        

        children.each do |child|
          formatting_attributes.each_pair do |key, value|
            child[key] ||= value
          end
        end
      end
      
      def collect_formatting_attributes(exceptions=[])
        formatting_attributes = {}
        (Nodes.formatting_attributes - exceptions).each do |key|
          formatting_attributes[key] = self[key]
          self.attributes.delete(key)
        end
        formatting_attributes
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

      def process(data, processor)
        children.each do |child|
          return child.process(data, processor) if child.evaluate(data, processor)
        end
        ''
      rescue Exception => e
        handle_processing_error(e, data, processor)        
      end
      
    end
  
    class ConditionalBlock < Node
      attr_fields %w{ disambiguate is-numeric is-uncertain-date locator
        position type variable match }
      
      def process(data, processor)
        children.map { |child| child.process(data, processor) }.join
      rescue Exception => e
        handle_processing_error(e, data, processor)        
      end
      
      def evaluate(data, processor)
        case
        when disambiguate?
          # CiteProc.log.warn "Choose disambiguate not implemented yet"
          false

        when is_numeric?
          data[is_numeric] && data[is_numeric].numeric?
          
        when is_uncertain_date?
          data[is_uncertain_date] && data[is_uncertain_date].uncertain?
          
        when has_locator?
          locator == data['locator'].to_s
          
        when has_position?
          # CiteProc.log.warn "Choose position not implemented yet"
          false

        when has_type?
          matches?(type.split(/\s+/)) { |type| type == data['type'].to_s }
          
        when has_variable?
          matches?(variable.split(/\s+/)) { |variable| !data[variable].nil? }
          
        when self.is_a?(Else)
          true
          
        else
          CiteProc.log :warn, "conditional block #{ inspect } could not be evaluated"
          false
          
        end
      rescue Exception => e
        CiteProc.log.error "failed to evaluate item #{data.inspect}: #{ e.message }; returning false."
        false
      end
      
      # @returns true if &condition is true for any/all/none elements in the list
      def matches?(list, &condition)
        list.send([self['match'] || 'all', '?'].join, &condition)
      end
      
    end

  end
  
  %w{ If ElseIf Else }.each do |node_name|
    CSL::Nodes.const_set(node_name.to_sym, Class.new(CSL::Nodes::ConditionalBlock))
  end
  
end