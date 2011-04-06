require 'observer'

module CiteProc

  class Item
    include Comparable
    include Observable
    include Support::Attributes
    
    attr_fields Variable.fields
    attr_fields %w{ locator label suppress-author author-only prefix suffix }
    
    def initialize(attributes={}, filter=nil)
      self.merge!(attributes)
      yield self if block_given?
    end
    
    def self.filter(attributes, filter)
      # TODO
    end
    
    # @see CSL::Nodes::Group
    alias :access :[]
    def [](key)
      value = access(key)
      changed
      notify_observers(key, value)
      value
    end
    
    def merge!(other)
      other = other.attributes unless other.is_a?(Hash)
      other.each_pair { |key, value| self.attributes[key] = Variable.parse(value, key) }
      self
    end

    def reverse_merge!(other)
      other = other.attributes unless other.is_a?(Hash)
      other.each_pair { |key, value| self.attributes[key] ||= Variable.parse(value, key) }
      self
    end
    
    def to_s
      self.attributes.inspect
    end
    
    
    def <=>(other)
      self.attributes <=> other.attributes
    end
  end

end