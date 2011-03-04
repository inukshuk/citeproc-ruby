#--
# CiteProc-Ruby
# Copyright (C) 2009-2011	Sylvester Keil <sylvester.keil.or.at>
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
  
  # == Term
  #
  # Terms are localized strings. For example, if a style specifies that the
  # term "and" should be used, the string that appears in the style output
  # depends on the locale: "and" for English, "und" for German. Terms are
  # defined using cs:term elements, child elements of cs:terms, itself a child
  # element of cs:locale. Terms are identified by the value of the name
  # attribute of cs:term. Two types of terms exist: simple terms, where the
  # content of the cs:term is the localized string, and compound terms, where
  # cs:term includes the two child elements cs:single and cs:multiple, which
  # respectively contain the singular and plural variant of the term (e.g.
  # "page" and "pages"). Some terms are defined for multiple forms. In these
  # cases, multiple cs:term element share the same value of name, but differ
  # in the value of the optional form attribute. The different forms are:
  #
  # * "long" - the default, e.g. "editor" and "editors" for the term "editor"
  # * "short" - e.g. "ed" and "eds" for the term "editor"
  # * "verb" - e.g. "edited by" for the term "editor"
  # * "verb-short" - e.g. "ed" for the term "editor"
  # * "symbol" - e.g. "§" for the term "section"
  #  
  # The plural attribute can be set to choose either the singular (value
  # "false", the default) or plural variant (value "true") of a term. In
  # addition, the form attribute can be set to select the desired term form
  # ("long" [default], "short", "verb", "verb-short" or "symbol"). If for a
  # given term the desired form does not exist, another form may be used:
  # "verb-short" reverts to "verb", "symbol" reverts to "short", and "verb"
  # and "short" both revert to "long".
  #
  class Term
    include Attributes

    attr_fields %w{ name long short verb verb-short symbol gender }
    
    def initialize(argument=nil, &block)
      case
      when argument.nil?

      when argument.is_a?(Hash)
        merge!(argument)
      
      when argument.is_a?(Nokogiri::XML::Node)
        parse!(argument)
        
      when argument.is_a?(String) && argument.match(/^<term/)
        parse!(Nokogiri::XML.parse(argument).root)
      
      when argument.is_a?(String) || argument.is_a?(Symbol)
        self['name'] = argument.to_s
      
      else
        CiteProc.log.warn "failed to create new Term from #{ argument.inspect }"
        
      end
      
      yield self if block_given?
    end
      
    
    # @returns a hash containing all the terms in the given document
    def self.build(doc)
      terms = Hash.new { |h,k| h[k] = Term.new(k) }
      doc.css('terms term').each { |term| terms[term['name']].parse!(term) }

      terms
    end
    
    def parse!(node)
      raise(ArgumentError, "failed to parse node; expected <term>, was: #{ node.inspect }") unless node.name == 'term'
      
      self['name'] = node['name']
      self['gender'] = node['gender']
      self[node['form'] || node['gender-form'] || 'long'] = Hash[%w{ singular plural }.zip(node.children.map(&:content))]
      
    end
    
    def singularize(options={})
      options['plural'] = 'false'
      to_s(options)
    end

    def pluralize(options={})
      options['plural'] = 'true'
      to_s(options)
    end
    
    def to_s(options={})
      options['plural'] = ['', 'false', '1', 'never'].include?(options['plural'].to_s) ? 'singular' : 'plural'
      
      term = case options['form']
        when 'verb-short' then verb_short || verb || long
        when 'symbol'     then symbol || short || long
        when 'verb'       then verb || long
        when 'short'      then short || long
        else long
      end || {}
      
      term[options['plural']].to_s
    rescue Exception => e
      CiteProc.log.error "failed to convert Term to String: #{ e.message }"
      ''
    end
    
    def empty?
      long.nil? && short.nil? && verb.nil? && verb_short.nil? && symbol.nil?
    end
    
    def has_gender?
      !gender.nil?
    end
    
    %w{ masculine feminine neutral }.each do |gender|
      define_method "is_#{gender}?" do
        self['gender'] == gender
      end
    end
    
  end
  
end