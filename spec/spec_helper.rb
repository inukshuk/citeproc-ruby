begin
  require 'simplecov'
  require 'debugger'
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
