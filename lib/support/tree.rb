module Support
  module Tree
    extend Enumerable
    
    attr_accessor :parent, :node_name
    
    def self.included(base)
      base.extend(ClassMethods)
    end
    
    def name
      node_name || self.class.name.split(/::/).last.gsub(/([[:lower:]])([[:upper:]])/) { [$1, $2].join('-') }.downcase
    end
    
    def children
      @children ||= []
    end

    def find_children_by_name(name)
      children.select { |node| node.name == name.to_s }
    end
    
    def has_children?; !children.empty?; end
    
    def each
      descendants.each { |child| yield child }
    end
    
    def descendants!
      @descendants = children + children.map(&:children).flatten
    end
    
    def descendants; @descendants || descendants!; end
    
    def add_children(*args)
      args.flatten.compact.each { |node| node.parent = self; children << node }
      self
    end
    
    alias :add_child :add_children
    
    def ancestors!
      @ancestors = root? ? [] : [parent] + parent.ancestors!
    end

    def ancestors; @ancestors || ancestors!; end
    
    def depth
      ancestors.length
    end
    
    def root!
      @root = root? ? self : parent.root!
    end

    def root; @root || root!; end
    
    def root?; parent.nil?; end
    
    module ClassMethods
      
      def attr_children(*arguments)
        arguments.flatten.each do |name|

          unless respond_to?(name) || respond_to?("#{name}!")
            define_method(name) do
              instance_variable_get("@#{name}") || send("#{name}!")
            end
          
            define_method("#{name}!") do
              instance_variable_set("@#{name}", find_children_by_name(name))
            end
          end
          
        end
      end
      
    end
  end
end