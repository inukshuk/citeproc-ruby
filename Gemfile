source 'https://rubygems.org'
gemspec

#gem 'citeproc', :github => 'inukshuk/citeproc'
#gem 'csl', :github => 'inukshuk/csl-ruby'

group :development, :test do
  gem 'rake', '~>10.0'
  gem 'rspec', '~>3.0', '<3.2.0'
  gem 'cucumber', '~>2.3'
end

group :debug do
  if RUBY_VERSION >= '2.0'
    gem 'byebug', :require => false, :platforms => :mri
  else
    gem 'debugger', :require => false, :platforms => :mri
  end

  gem 'ruby-debug', :require => false, :platforms => :jruby

  gem 'rubinius-debugger', :require => false, :platforms => :rbx
  gem 'rubinius-compiler', :require => false, :platforms => :rbx
end

group :optional do
  if RUBY_VERSION >= '2.2.2'
    gem 'edtf', '~>3.0'
  else
    gem 'edtf', '~>2.0'
  end
	gem 'chronic'
end

group :extra do
  gem 'guard', '~>2.2'
  gem 'guard-rspec'
  gem 'guard-cucumber'
  gem 'rb-fsevent'
  gem 'pry'
	gem 'yard', '~>0.8', :platforms => :mri
	gem 'redcarpet', '~>3.0', :platforms => :mri
end

group :coverage do
  gem 'simplecov', '~>0.8'
  gem 'rubinius-coverage', :platforms => :rbx
  gem 'coveralls', :require => false
end

group :rbx do
  gem 'rubysl', :platforms => :rbx
  gem 'racc', :platforms => :rbx
  gem 'json', '~>1.8', :platforms => :rbx
end
