require 'rubygems'
require 'citeproc'
require 'json'
require 'yaml'

RSpec.configuration do |c|
end

module CSL
  module Tests
    def self.load(type=:processor)
      path = File.expand_path("../../resource/test/#{type}/", __FILE__)
      Dir.entries(path)[2..-1].map { |file| JSON.parse(File.read(File.join(path,file))) }
    end
    
    NodeFixtures = YAML.load(File.read(File.expand_path("../fixtures/nodes.yaml", __FILE__)))
    
  end
  
end