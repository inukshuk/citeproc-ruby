module CiteProc

  class Selector
    include Support::Attributes
    
    attr_fields :select, :include, :exclude, :quash
    
    
    def initialize(argument = {})
      key_filter['all'] = 'select'
      key_filter['any'] = 'include'
      key_filter['none'] = 'exclude'
      key_filter['skip'] = 'quash'
      
      merge(normalize(argument))
    end
    
    def type
      attributes.keys.detect { |k| [:select, :include, :exclude].include?(k.to_sym) }
    end
    
    # @returns one of :all?, :any?, :none?
    def matcher
      type == 'include' ? :any? : type == 'exclude' ? :none? : :all?
    end
    
    def conditions
      attributes[type] || []
    end

    def matches?(item)
      conditions.send(matcher) { |condition| match(item, condition) }
    end
    
    def skip?(item)
      has_quash? && quash.all? { |condition| match(item, condition) }
    end
        
    def to_proc
      Proc.new { |item| matches?(item) && !skip?(item) }
    end
        
    protected
    
    def match(item, condition)
      values, expected = [item[condition['field']]].flatten.map(&:to_s), [condition['value']].flatten
      expected & values != []
    end
    
    def normalize(argument)
      case
      when [String, Symbol].include?(argument.class) && !(argument.to_s =~ /^\s*\{/)
        { argument.to_s => [] }
      else
        argument
      end
    end
    
  end

end