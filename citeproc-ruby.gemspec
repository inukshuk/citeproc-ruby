# -*- encoding: utf-8 -*-
require File.expand_path('../lib/citeproc/version', __FILE__)

Gem::Specification.new do |s|
  s.name = 'citeproc-ruby'
  s.version = CiteProc::VERSION.dup
  s.required_rubygems_version = Gem::Requirement.new('>= 1.3.6') if s.respond_to? :required_rubygems_version=
  s.authors = ['Sylvester Keil']
  s.description = %q{A CSL (Citation Style Language)Processor}
  s.email = ['http://sylvester.keil.or.at']
  s.homepage = 'http://github.com/inukshuk/citeproc-ruby'
  s.require_paths = ['lib']
  s.summary = %q{A CSL 1.0 (Citation Style Language) Processor}
  s.executables = [] # `git ls-files -- bin/*`.split('\n').map{ |f| File.basename(f) }
  s.files = `git ls-files -- {lib,spec}/* resource/{locale,schema,style}`.split("\n")  
  s.test_files = `git ls-files -- {spec}/*`.split("\n")

  s.has_rdoc = true
  s.rdoc_options = %w{--charset=UTF-8 --line-numbers --inline-source --title "CiteProc-Ruby Documentation" --main README.md --webcvs=http://github.com/inukshuk/citeproc-ruby/tree/master/}
  s.extra_rdoc_files = %w{README.md}

  s.add_dependency('logging', '~> 1.5')
  s.add_dependency('nokogiri', '~> 1.4')

  s.add_development_dependency('bundler', '~> 1.0')
  s.add_development_dependency('rdoc', '~> 2.5')
  s.add_development_dependency('rake', '>= 0.8')
  s.add_development_dependency('rspec', '~> 2.5')
  s.add_development_dependency('cucumber', '~> 0.3')
end

# vim: syntax=ruby