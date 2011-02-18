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

module CiteProc
  
  # A bibliography is an array of bibliographic entries and, optionally,
  # a list of errors. The bibliography should be format agnostic; it is
  # simply encapsulates two lists.
  class Bibliography
    
    attr_accessor :data, :errors, :options
    
    def initialize
      @data = []
      @errors = []
      @options = {}
    end

    # @data proxy
    [:[], :[]=, :<<, :map, :each, :empty?, :push, :pop, :unshift, :+, :concat].each do |method_id|
      define_method method_id do |*args, &block|
        @data.send(method_id, *args, &block)
      end
    end

  end
end