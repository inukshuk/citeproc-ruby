# -*- ruby -*-
$LOAD_PATH.unshift File.expand_path("../lib", __FILE__)

require 'rubygems'
require 'rake'
require 'rake/clean'
require 'rake/rdoctask'

require 'citeproc/version'

task :default => []

begin
  require 'rspec/core/rake_task'
rescue LoadError
  puts 'To use rspec-2 for testing you must install the rspec-2 gem:\n\t\tgem install rspec'
  exit(0)
end

desc "Run rspec-2 on the specs in ./specs"
RSpec::Core::RakeTask.new(:spec) do |t|
  t.rspec_opts = ['-c', '-f progress', '-r ./spec/spec_helper.rb']
  t.pattern = 'spec/**/*_spec.rb'
end

desc "Run the citeproc-test suite"
RSpec::Core::RakeTask.new(:test) do |t|
  t.rspec_opts = ['-c', '-f progress', '-r ./spec/spec_helper.rb']
  t.pattern = 'spec/**/*_test.rb'
end


Rake::RDocTask.new(:rdoc_task) do |rd|
  rd.main = 'README.md'
  rd.title = "CiteProc-Ruby Documentation"
  rd.rdoc_files.include('README.md',"lib/**/*.rb")
  rd.rdoc_dir = "doc/html"
  rd.options << '--webcvs=http://github.com/inukshuk/csl-ruby/tree/master/'
end

CLEAN.include('doc/html')

# vim: syntax=ruby