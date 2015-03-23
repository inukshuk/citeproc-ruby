require 'bundler'
begin
  Bundler.setup
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end

begin
  require 'simplecov'
  require 'coveralls' if ENV['CI']
rescue LoadError
  # ignore
end

begin
  case
  when RUBY_PLATFORM == 'java'
    # require 'debug'
    # Debugger.start
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

require 'citeproc/ruby'

module Fixtures
	PATH = File.expand_path('../fixtures', __FILE__)

	Dir[File.join(PATH, '*.rb')].each do |fixture|
		require fixture
	end
end

module SilentWarnings
  require 'stringio'
  #
  # Adapted form silent_warnings gist by @avdi
  # https://gist.github.com/1170926
  #
  def silent_warnings
    original_stderr = $stderr
    $stderr = StringIO.new
    yield
  ensure
    $stderr = original_stderr
  end
end

RSpec.configure do |config|
  config.include(SilentWarnings)
  config.include(Fixtures)

  config.before :all do
    @style_root, @locale_root = CSL::Style.root, CSL::Locale.root

    CSL::Style.root  = File.join(Fixtures::PATH, 'styles')
    CSL::Locale.root = File.join(Fixtures::PATH, 'locales')
  end

  config.after :all do
    CSL::Style.root, CSL::Locale.root = @style_root, @locale_root
  end

end
