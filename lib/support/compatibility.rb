
# Remove the 'id' and 'type' methods in Ruby 1.8, as they're used all over
# the source
if RUBY_VERSION < "1.9.0"
  class Object
    undef_method :id
    undef_method :type
  end
end

# Robust solutions for Unicode
if RUBY_PLATFORM == 'java'
  require 'java'
  
  module Support
    def self.upcase(string)
      java.lang.String.new(string).to_upper_case(java.util.Locale::ENGLISH).to_s
    end
    
    def self.downcase(string)
      java.lang.String.new(string).to_lower_case(java.util.Locale::ENGLISH).to_s
    end
  end
  
else

  begin
    require 'unicode'
    
    module Support
      def self.upcase(string)
        Unicode.upcase(string)
      end
      
      def self.downcase(string)
        Unicode.downcase(string)
      end
    end
    
  rescue LoadError
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
  end
end