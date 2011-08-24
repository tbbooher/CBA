require 'vcr'
require 'webmock/test_unit'

VCR.config do |c|
  c.cassette_library_dir = 'vcr_cassettes'
  c.stub_with :webmock
  c.default_cassette_options = { :record => :once }
end

