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
  s.licenses     = ['BSD-2-Clause']
  s.date        = Time.now.strftime('%Y-%m-%d')
  s.homepage    = 'https://github.com/inukshuk/citeproc-ruby'
  s.summary     = 'A Citation Style Language (CSL) cite processor'
  s.description =
		"""
    CiteProc-Ruby is a Citation Style Language (CSL) 1.0.1 compatible cite
    processor implementation written in pure Ruby.
		""".gsub(/^\s+/, '')

  s.required_ruby_version = '>= 1.9.3'
  s.add_dependency 'citeproc', '~> 1.0', '>= 1.0.9'
  s.add_dependency 'csl', '~> 2.0'
  s.add_dependency 'observer', '< 1.0'

  s.files        = `git ls-files`.split("\n") - %w{
    .gitignore
    .rspec
    .rubocop.yml
    .simplecov
    citeproc-ruby.gemspec
  } - `git ls-files -- {spec,features}/*`.split("\n")

  s.require_path = 'lib'
end

# vim: syntax=ruby
