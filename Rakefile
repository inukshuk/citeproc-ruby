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


RSpec::Core::RakeTask.new(:spec) do |t|
  t.rspec_opts = ['--color', '--format progress', '-r ./spec/spec_helper.rb']
end

namespace :spec do
  desc "Run the citeproc-test suite"
  RSpec::Core::RakeTask.new(:test) do |t|
    t.rspec_opts = ['--color', '--format progress', '--format documentation --out doc/tests.txt', '-r ./spec/spec_helper.rb']
    t.pattern = 'spec/citeproc/citeproc_spec.rb'
  end

  desc "Run all RSpec code examples"
  task :all => [:citeproc, :csl]

  RSpec::Core::RakeTask.new(:citeproc) do |t|
    t.rspec_opts = ['--color', '--format progress', '--format documentation --out doc/citeproc_spec.txt --no-color', '-r ./spec/spec_helper.rb']
    t.pattern = 'spec/citeproc/**/*_spec.rb'
  end

  RSpec::Core::RakeTask.new(:csl) do |t|
    t.rspec_opts = ['--color', '--format progress', '--format documentation --out doc/csl_spec.txt --no-color', '-r ./spec/spec_helper.rb']
    t.pattern = 'spec/csl/**/*_spec.rb'
  end  
end


Rake::RDocTask.new(:rdoc_task) do |rd|
  rd.main = 'README.md'
  rd.title = "CiteProc-Ruby Documentation"
  rd.rdoc_files.include('README.md','LICENSE',"lib/**/*.rb")
  rd.rdoc_dir = "doc/html"
  rd.options << '--webcvs=http://github.com/inukshuk/citeproc-ruby/tree/master/'
end

CLEAN.include('doc/html')

# vim: syntax=ruby