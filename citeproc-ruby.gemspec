# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib/', __FILE__)
$:.unshift lib unless $:.include?(lib)

require 'citeproc/ruby/version'

Gem::Specification.new do |s|
  s.name        = 'citeproc-ruby'
  s.version     = CiteProc::Ruby::VERSION.dup
  s.platform    = Gem::Platform::RUBY

  s.authors     = ['Sylvester Keil']
  s.email       = ['http://sylvester.keil.or.at']
  
  s.homepage    = 'https://github.com/inukshuk/citeproc-ruby'
  s.summary     = 'A Citation Style Language (CSL) cite processor'
  s.description =
		"""
    CiteProc-Ruby is a Citation Style Language (CSL) 1.0.1 compatible cite
    processor implementation written in pure Ruby.
		""".gsub(/^\s+/, '')

  s.license     = 'AGPL'
  s.date        = Time.now.strftime('%Y-%m-%d')

  s.add_dependency 'citeproc', '1.0.0.pre10'
  s.add_dependency 'csl', '1.0.0.pre15'

  s.add_development_dependency 'cucumber', '~>1.1'
  s.add_development_dependency 'rspec', '~>2.7'
  s.add_development_dependency 'rake', '~>0.9'

  s.files        = `git ls-files`.split("\n")
  s.test_files   = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables  = []
  s.require_path = 'lib'

  s.has_rdoc      = 'yard'
end

# vim: syntax=ruby
