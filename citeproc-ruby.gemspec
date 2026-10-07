require_relative 'lib/citeproc/ruby/version'

Gem::Specification.new do |s|
  s.name        = 'citeproc-ruby'
  s.version     = CiteProc::Ruby::VERSION
  s.authors     = ['Sylvester Keil']
  s.email       = ['sylvester@keil.or.at']
  s.homepage    = 'https://github.com/inukshuk/citeproc-ruby'
  s.licenses    = ['BSD-2-Clause']
  s.summary     = 'A Citation Style Language (CSL) cite processor'
  s.description = <<~EOS
    CiteProc-Ruby is a Citation Style Language (CSL) 1.0.2 compatible cite
    processor implementation written in pure Ruby.
  EOS

  s.metadata = {
    'source_code_uri' => 'https://github.com/inukshuk/citeproc-ruby',
    'bug_tracker_uri' => 'https://github.com/inukshuk/citeproc-ruby/issues',
    'rubygems_mfa_required' => 'true'
  }

  s.required_ruby_version = '>= 3.1'
  s.add_dependency 'citeproc', '~> 1.4'
  s.add_dependency 'csl', '~> 2.5'
  s.add_dependency 'observer', '< 1.0'

  s.files = Dir['lib/**/*.rb', 'BSDL', 'README.md']
end
