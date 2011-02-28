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

  class Item
    include Comparable
    include Attributes
    
    attr_fields Variable.fields
    
    attr_accessor :processor
    
    def initialize(attributes={}, filter=nil)
      self.merge!(attributes)
      yield self if block_given?
    end
    
    def self.filter(attributes, filter)
      # TODO
    end
    
    def merge!(arguments)
      arguments = [arguments] unless arguments.is_a?(Array)
      arguments.each { |argument| argument.map { |key, value| self.attributes[key] = Variable.parse(value, key) }}
    end

    def to_s
      self.attributes.inspect
    end
    
    # alias :access :[]
    # 
    # @returns the variable with the given id. In case of a normal
    # CiteProc::Variable, the variable is returned as a string.
    # def [](id)
    #   value = access(id)
    #   value.class == CiteProc::Variable ? value.value : value
    # end
    
    # Compares two items according to the sort keys specified in the processor
    # assigned to the first item.
    #
    # @returns -1, 0, 1
    #
    def compare(other, mode=:citation)
      return self <=> other if @processor.nil?
      
      @processor.style.send(mode).sort_keys.each do |key|
        case
        when key.has_key?('variable')
          variable = key['variable']
          this, that = self[variable], other[variable]
                  
        when key.has_key?('macro')
          macro = @processor.style.macros[key['macro']]
          this, that = macro.process({'id' => self['id'].to_s}, @processor),
            macro.process({'id' => other['id'].to_s}, @processor) 

        else
          CiteProc.log.warn "sort key #{ key.inspect } contains no variable or macro definition."
        end

        comparison = this <=> that
        comparison = comparison ? comparison : that.nil? ? 1 : -1
        
        comparison = comparison * -1 if key['sort'] == 'descending'
        return comparison unless comparison.zero?
      end
      
      0
    end
    
    def <=>(other)
      self.attributes <=> other.attributes if @processor.nil?
      self.compare(other)
    end
  end

end