
begin
  require 'unicode_utils'

  module Support
    def self.upcase(string)
      UnicodeUtils.upcase(string)
    end
    
    def self.downcase(string)
      UnicodeUtils.downcase(string)
    end
  end
  
rescue LoadError
  begin
    require 'active_support/multibyte/chars'
    
    module Support
      def self.upcase(string)
        ActiveSupport::Multibyte::Chars.new(string).upcase.to_s
      end
      
      def self.downcase(string)
        ActiveSupport::Multibyte::Chars.new(string).downcase.to_s
      end
    end
    
  rescue LoadError
    
    module Support
      def self.upcase(string)
        string.upcase
      end
      
      def self.downcase(string)
        string.downcase
      end
    end
    
  end
end