# -*- ruby -*-
$LOAD_PATH.unshift File.expand_path("../lib", __FILE__)

require 'rubygems'
require 'rake'
require 'rake/clean'
require 'rake/rdoctask'

require 'citeproc/version'

task :default => []

Rake::RDocTask.new(:rdoc_task) do |rd|
  rd.main = 'README.md'
  rd.title = "CiteProc-Ruby Documentation"
  rd.rdoc_files.include('README.md',"lib/**/*.rb")
  rd.rdoc_dir = "doc/html"
  rd.options << '--webcvs=http://github.com/inukshuk/csl-ruby/tree/master/'
end

CLEAN.include('doc/html')

# vim: syntax=ruby