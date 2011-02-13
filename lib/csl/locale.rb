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

  class Locale

    # Class Instance Variables
    @path = File.expand_path('../../../resource/locale/', __FILE__)
    @default = 'en-US'

    class << self; attr_accessor :path, :default end    
    
    attr_accessor :language, :region

    def initialize(tag=nil)
      set(tag || Locale.default)
    end
    
    def set(tag)
      @language, @region = tag.to_s.split(/-/)
    end

    def tag
      [@language, @region].join('-')
    end
    
    def terms
      @terms = @terms || build_terms
    end
    
    def [](tag)
      terms[tag]
    end

    # @example
    # #options['punctuation-in-quotes'] => 'true'
    def options
      @options = @options || Hash.new { |h,k| @doc.at_css('style-options')[k.to_s] }
    end
    
    alias :style_options :options

    # @example
    # #date(:numeric)['month']['suffix'] => '/'
    def date(form=:text)
      @date = @date || Hash[@doc.css("date[form='#{form}'] > date-part").map { |d| [d['name'], Hash[d.to_a]] }]
    end
    
    # Around Alias Chains to call reload whenver locale changes
    [:language=, :region=, :set].each do |method|
      original = [:original, method].join('_')
      alias_method original, method
      define_method method do |*args|
        self.send(original, *args)
        reload!()
      end
    end

    # Reloads the XML file. Called automatically whenever the locale changes.
    def reload!
      @options, @date, @terms = nil
      @doc = Nokogiri::XML(File.open(document_path)) { |config| config.strict.noblanks }
    rescue Exception => e
      CiteProc.log.error "Failed to open locale file, falling back to default: #{e.message}"
      unless tag == Locale.default
        @language, @region = Locale.default.split(/-/)
        retry
      end
    end

    
    private
    
    def build_terms
      @terms = Hash.new { |h,k| h[k] = Hash.new({}) }
      
      @doc.css('terms term').each do |t|
        @terms[t['name']][t['form'] || 'default'] = t.children.map(&:content)
      end
      
      @terms
    end

    def document_path
      File.expand_path("./locales-#{@language}-#{@region}.xml", Locale.path)
    end
     
  end
end