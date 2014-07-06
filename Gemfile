source 'https://rubygems.org'
gemspec

#gem 'citeproc', :github => 'inukshuk/citeproc.git'
#gem 'csl', :github => 'inukshuk/csl-ruby.git'

group :development, :test do
  gem 'rake', '~>10.0'
  gem 'rspec', '~>3.0'
  gem 'cucumber', '~>1.2'
  gem 'simplecov', '~>0.8'
  gem 'rubinius-coverage', :platforms => [:rbx]
  gem 'coveralls', :require => false
end

group :debug do
  gem 'ruby-debug', :require => false, :platforms => [:jruby]
  gem 'debugger', :require => false, :platforms => [:mri]
  gem 'rubinius-debugger', :require => false, :platforms => [:rbx]
  gem 'rubinius-compiler', :require => false, :platforms => [:rbx]
end

group :optional do
	gem 'edtf'
	gem 'chronic'
end

group :extra do
  gem 'guard', '~>2.2'
  gem 'guard-rspec'
  gem 'guard-cucumber'
  gem 'rb-fsevent', '~>0.9.1'
  gem 'pry'
	gem 'yard', '~>0.8', :platforms => [:mri]
	gem 'redcarpet', '~>3.0', :platforms => [:mri]
end

platform :rbx do
  gem 'rubysl'
  gem 'racc'
  gem 'json'
end
