
2
3
4
5
6
7
8
9
10
11
12
13
14
15
16
17
18
19
20
21
22
23
24
25
26
27
28
29
30
31
32
33
34
35
36
37
38
39
40
41
42
43
44
45
46
47
48
49
50
51
52
53
54
55
56
57
58
59
60
61
62
63
64
65
66
67
68
69
70
71
72
73
74
75
76
77
78
79
80
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