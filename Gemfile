source 'http://rubygems.org'

gem 'simplecov', '>= 0.4.0', :require => false, :group => :test
gem 'httparty'

gem "rails", "3.1.0.rc5"

group :assets do
  gem 'sass-rails', "~> 3.1.0.rc"
  gem 'coffee-script'
  gem 'uglifier'
  gem 'json'
  gem 'jquery-rails'
#  gem 'therubyracer'
  gem 'execjs'
  gem 'sprockets', '~> 2.0.0.beta.12'
end

# Bundle gems needed for Mongoid
gem "mongoid", "2.1.6" #  :path => "/Users/aa/Development/R31/mongoid-1" #"2.1.6"
gem "bson_ext"  #, "1.1.5"

# Bundle gem needed for Devise and cancan
gem "devise", "~>1.4.0" # ,"1.1.7"
gem "cancan"

gem "googlecharts"
gem 'omniauth', :git => 'git://github.com/intridea/omniauth.git'

# we need some stuff too (tbb)
gem 'simple_form'

# for deployment
gem "capistrano"

# and server
#gem 'unicorn'

# time to connect to opencongress
gem 'json'
gem 'geocoder'

#group :after_initialize do
gem 'nokogiri' #,  :git => 'git://github.com/ender672/nokogiri.git'# :git => 'git://github.com/tenderlove/nokogiri.git'
gem 'feedzirra' #ls
gem 'sax-machine'

# Bundle gem needed for paperclip and attachments
gem "mongoid-paperclip", :require => "mongoid_paperclip"

# MongoID Extensions and extras
gem 'mongoid-tree', :require => 'mongoid/tree'
gem 'mongoid_fulltext'

# Bundle gems for views
gem "haml"
gem "will_paginate", "3.0.pre4"
gem 'escape_utils'
gem "RedCloth", "4.2.5" #"4.2.4.pre3 doesn't work with ruby 1.9.2-p180

# Gems by iboard.cc/CBA
gem "jsort", "~> 0.0.1"

# Markdown
# do "easy_install pygments" on your system
gem 'redcarpet'
gem 'albino'

# Bundle gems for development
group :development do
#  gem "nifty-generators"
  gem "rails-erd"
  gem 'rdoc'
  gem "rails3-generators"
  gem "ruby-debug19"
  #gem "ruby-debug-base19", :git => "git://github.com/JetBrains/ruby-debug-base19.git"
  gem "ruby-debug-ide", :git => "git://github.com/JetBrains/ruby-debug-ide.git"
#  gem 'unicorn'
  gem 'yard'
end