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
  when defined?(RUBY_ENGINE) && RUBY_ENGINE == 'rbx'
    require 'rubinius/debugger'
  when RUBY_VERSION < '2.0'
    require 'debugger'
  else
    require 'byebug'
  end
rescue LoadError
  # ignore
end

require 'rspec/mocks/standalone'
require 'citeproc/ruby'

module Fixtures
	PATH = File.expand_path('../../../spec/fixtures', __FILE__)

	Dir[File.join(PATH, '*.rb')].each do |fixture|
		require fixture
	end
end

World(Fixtures)
