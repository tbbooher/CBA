require 'rubygems'
require 'test/unit'
require 'vcr'
# /home/passenger/.rvm/gems/ruby-1.9.2-p180@cba/gems/vcr-1.11.3

VCR.config do |c|
  c.cassette_library_dir = 'vcr_cassettes'
  c.stub_with :webmock
  c.default_cassette_options = { :record => :once }
end

