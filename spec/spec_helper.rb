require 'rubygems'
require 'citeproc'
require 'json'

RSpec.configuration do |c|
end

module CSL
  module Tests
    def self.load(type=:processor)
      path = File.expand_path("../#{type}/", __FILE__)
      Dir.entries(path)[2..-1].map { |file| JSON.parse(File.read(File.join(path,file))) }
    end
  end
end