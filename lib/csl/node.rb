module CSL
  
  def Node(*args, &block)
    Node.parse(*args, &block)
  end
  
  module_function :Node
  
  class Node
    include Support::Attributes
    include Support::Tree

    def self.parse(*args, &block)
      return if args.compact.empty?
      
      node = args.detect { |argument| argument.is_a?(Nokogiri::XML::Node) } ||
        raise(ArgumentError, "arguments must contain an XML node; was #{ args.map(&:class).inspect }")
    
      name = node.name.split(/[\s-]+/).map(&:capitalize).join
      klass = CSL.const_defined?(name) ? CSL.const_get(name) : self

      klass.new({ :node => node }, &block)
    end
    
    def initialize(arguments = {})
      parse(normalize(arguments[:node])) if arguments.has_key?(:node)
      
      merge!(arguments[:attributes])
      
      @node_name = arguments[:name].to_s if arguments.has_key?(:name)
      
      yield self if block_given?
    end

    def name
      node_name || self.class.name.split(/::/).last.gsub(/([[:lower:]])([[:upper:]])/) { [$1, $2].join('-') }.downcase
    end
    
    alias :name= :node_name=

    def style!
      @style = root!.is_a?(Style) ? nil : root
    end
    
    def style; @style || style!; end

    def parse(node)      
      @node_name = node.name

      node.attributes.values.each { |a| attributes[a.name] = a.value }
      add_children(node.children.map { |child| Node.parse(child) })
    end

    def to_xml
    end

    protected

    def normalize(node)
      case node
      when Nokogiri::XML::Node
        node
      when String
        # TODO file path (e.g. locale or style)
        Nokogiri::XML.parse(node) { |config| config.strict.noblanks }.root
      else
        raise(ArgumentError, "failed to parse #{ node.inspect }")
      end
    end

  end
end