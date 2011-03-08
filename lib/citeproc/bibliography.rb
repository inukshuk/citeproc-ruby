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
  
  # A bibliography is an array of bibliographic entries and, optionally,
  # a list of errors. The bibliography should be format agnostic; it is
  # simply encapsulates two lists.
  class Bibliography
    
    def initialize(*args)
      args.each { |argument| parse_argument(argument) }
      
      yield self if block_given?
    end

    def data; @data ||= []; end
    def errors; @errors ||= []; end
    def options; @options ||= {}; end

    # @data proxy
    [:[], :[]=, :<<, :map, :each, :empty?, :push, :pop, :unshift, :+, :concat].each do |method_id|
      define_method method_id do |*args, &block|
        @data.send(method_id, *args, &block)
      end
    end

    def to_json
      [options.merge('bibliography-errors' => errors), data].to_json
    end
    
    def to_s
      [options['bibstart'] || '<div class="csl-bib-body">', data.map { |d| "  <div class=\"csl-entry\">#{d}</div>" }, options['bibend'] || '</div>'].flatten.join("\n")
    end
    
    protected
    
    def parse_argument(argument)
      case
      when argument.is_a?(String)
        parse_argument(JSON.parse(argument))
      when argument.is_a?(Hash)
        parse_attributes(argument)
      when argument.is_a?(Array) && argument.length == 2 && argument[0].is_a?(Hash) && argument[1].is_a?(Array)
        parse_attributes(argument[0])
        @data = argument[1]
      when argument.is_a?(Array)
        @data = argument
      else
        CiteProc.log.warn "failed to initialize Bibliography from argument #{ argument.inspect }." unless argument.nil?
      end
    end
    
    def parse_attributes(attributes)
      @errors = attributes.delete('bibliography-errors') || []
      @options = {}.merge(attributes)
    end
    
  end
end