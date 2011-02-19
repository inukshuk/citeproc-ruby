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

module CSL

  class Style

    @schema = File.expand_path('../../resource/schema/csl.rnc', __FILE__)
    @path = File.expand_path('../../../resource/style', __FILE__)
    
    class << self; attr_accessor :path, :schema; end
        
    def initialize(style='apa')
      open(style)
    end
    
    def reset
      @doc = nil
      @attributes = {}
    end
    
    # @param style A CSL stream, a file, the name of Style in the local repository, or an URI
    def open(style)
      reset
      @doc = Nokogiri::XML(locate(style)) { |config| config.strict.noblanks }
    end
    
    # Returns the CSL Relax NG schema defintion.
    def schema
      @attributes[:schema] ||= Nokogiri::XML::RelaxNG(File.open(Style.schema))
    end
    
    # Validates the current style's source document against the CSL defintion.
    def validate
      schema.validate(@doc)
    end
    
    # Returns true if the current style's source document conforms to the CSL definition.
    def valid?
      validate.empty?
    end

    # Updates the current style using the URI returned by #link.
    def update!
      open(link)
    end
    
    def info
      @attributes[:info] ||= @doc.at_css('style > info')
    end

    [:title, :id].each do |method_id|
      define_method method_id do
        @attributes[method_id] ||= info.at_css(method_id.to_s).content
      end
    end
    
    def link
      @attributes[:link] ||= info.at_css('link')['href']
    end
    
    def macros
      @attributes[:macros] ||= Hash[@doc.css('style > macro').map { |m| [m[:name], Nodes::Macro.new(m, self)] } ]
    end
    
    [:citation, :bibliography].each do |method_id|
      define_method method_id do
        @attributes[method_id] ||= CSL::Nodes.const_get(method_id.to_s.capitalize).new(@doc.at_css("style > #{method_id}"), self)
      end
    end
    
    
    private
    
    def locate(resource)
      resource = resource.to_s
      return resource if resource.match(/^<(\?xml|style)/)
      return File.read(resource) if File.exists?(resource)
      
      local = File.join(Style.path, "#{resource}.csl")
      return File.read(local) if File.exists?(local)

      Kernel.open(resource)
    end
  end
    
end
