source :rubygems
gemspec

group :debug do
  gem 'debugger', '~>1.1.3', :platform => :mri_19
end

group :optional do
  gem 'oniguruma', '~>1.1.0', :platform => :mri_18
	gem 'edtf'
	gem 'chronic'
end

group :extra do
  gem 'simplecov', '~>0.6.4'

  gem 'guard', '~>1.2'
  gem 'guard-rspec', '~>1.1'
  gem 'guard-cucumber', '~>1.2'
  gem 'rb-fsevent', '~>0.9.1'

	gem 'yard', '~>0.8', :platforms => [:mri_19]
	gem 'redcarpet', '~>2.1', :platforms => [:mri_19]
end
