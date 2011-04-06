module CiteProc
  
  module Format
    def self.default; CiteProc::Format::Default.new; end
  end
  
  class Formatter
  
    def format(*args)
      @format ||= CiteProc.default_format
      args.empty? ? @format : apply(args[0], args[1])
    end

    def format=(format)
      @format = Format.const_get(format.to_s.split(/[\s_-]+/).map(&:capitalize).join).new
    rescue Exception => e
      CiteProc.log :warn, "failed to set format to #{ format.inspect }", e
    end
    
    def apply(input='', attributes={})
      return input if attributes.nil? || input.nil? || input.empty?

      format.input = input
      
      CSL::Nodes.formatting_attributes.each do |attribute|
        method_id = ['set', attribute.gsub(/-/, '_')].join('_')
        
        if !attributes[attribute].nil? && format.respond_to?(method_id)
          format.send(method_id, attributes[attribute])
        end
      end
      
      format.finalize
    end
  
  end
  
end