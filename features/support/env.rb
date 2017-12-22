begin
  require 'simplecov'
  require 'coveralls' if ENV['CI']
rescue LoadError
  # ignore
end

begin
  case
  when RUBY_PLATFORM < 'java'
    require 'debug'
    Debugger.start
  else
    require 'byebug'
  end
rescue LoadError
  # ignore
end

require 'citeproc/ruby'

module Fixtures
	PATH = File.expand_path('../../../spec/fixtures', __FILE__)

	Dir[File.join(PATH, '*.rb')].each do |fixture|
		require fixture
	end
end

World(Fixtures)
