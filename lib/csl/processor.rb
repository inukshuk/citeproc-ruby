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

  def self.default_abbreviations
    Hash[
      'container', {},
      'collection-title', {},
      'authority', {},
      'institution', {},
      'title', {},
      'publisher', {},
      'publisher-place', {},
      'hereinafter', {}]
  end
  
  class Processor
    
    attr_reader :style, :schema, :bibliography, :abbreviations, :format
    attr_accessor :language, :data_store

    alias :ds :data_store
    
    def initialize
      @bibliography = Bibliography.new
      @abbreviations = { 'default' => CSL.default_abreviations }
    end

    def style=(style)
      @style = Nokogiri::XML(File.exists?(style) ? File.open(style) : style)
    end
    
    def schema=(schema)
      @schema = Nokogiri::XML::RelaxNG(File.exists?(schema) ? File.open(schema) : schema)
    end
    
    def valid?
      @schema.validate(@style).empty?
    end
    
    def format=(new_format)
    end
    
    def cite
    end

    def nocite
    end
    
    def compile
    end
    
  end
end