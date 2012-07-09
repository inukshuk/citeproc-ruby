begin
  require 'simplecov'
  require 'debugger'
rescue LoadError
  # ignore
end

require 'nokogiri'

require 'citeproc/ruby'


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
end
