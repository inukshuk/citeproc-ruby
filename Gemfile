source 'https://rubygems.org'
gemspec

group :development, :test do
  gem 'rake', '~>10.0'
  gem 'rspec', '~>2.13'
  gem 'cucumber', '~>1.2'
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
  gem 'simplecov', '~>0.8'
  gem 'rubinius-coverage', :platforms => [:rbx]

  gem 'guard', '~>2.2'
  gem 'guard-rspec'
  gem 'guard-cucumber'
  gem 'rb-fsevent', '~>0.9.1'

	gem 'yard', '~>0.8', :platforms => [:mri]
	gem 'redcarpet', '~>3.0', :platforms => [:mri]
end

platform :rbx do
  gem 'rubysl'
  gem 'racc'
  gem 'json'
end
