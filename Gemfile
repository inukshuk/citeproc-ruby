source 'https://rubygems.org'
gemspec

# gem 'csl', github: 'inukshuk/csl-ruby', branch: 'master'
# gem 'citeproc', github: 'inukshuk/citeproc', branch: 'master'

group :development, :test do
  gem 'rake'
  gem 'rspec'
  gem 'cucumber'
end

group :debug do
  gem 'debug', require: false, platforms: :mri
end

group :optional do
  gem 'edtf'
  gem 'ffi-icu'
end

group :coverage do
  gem 'simplecov', '>= 1.3', require: false
  gem 'simplecov-lcov', require: false
end
