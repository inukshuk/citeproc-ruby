require 'rubygems'
require 'citeproc'
require 'json'
require 'yaml'

RSpec.configuration do |c|
end

module CiteProc
  module Test
    module Fixtures
      Names = YAML.load(File.read(File.expand_path("../fixtures/names.yaml", __FILE__)))
      Dates = YAML.load(File.read(File.expand_path("../fixtures/dates.yaml", __FILE__)))
      Nodes = YAML.load(File.read(File.expand_path("../fixtures/nodes.yaml", __FILE__)))
      Processor = Hash[Dir.glob(File.expand_path("../../resource/test/processor/*.json", __FILE__)).map { |file| [file, JSON.parse(File.read(file))] }]
    end    
  end
end