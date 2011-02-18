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
  end

  module Test
    module Fixtures
      Names = YAML.load(File.read(File.expand_path("../fixtures/names.yaml", __FILE__)))
      Nodes = YAML.load(File.read(File.expand_path("../fixtures/nodes.yaml", __FILE__)))
    end
  end
end