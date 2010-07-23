$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

require 'rubygems'
require 'config_newton'
require 'fakefs/spec_helpers'
require 'spec'
require 'spec/autorun'

Spec::Runner.configure do |config|
  config.include FakeFS::SpecHelpers
end
