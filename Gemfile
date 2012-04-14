require 'rbconfig'
HOST_OS = Config::CONFIG['host_os']

source 'http://rubygems.org'

gem "rails", '3.2.3'
gem 'jquery-rails'

# Bundle edge Rails instead:
# gem 'rails',     :git => 'git://github.com/rails/rails.git'



# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails', '~> 3.2.3'
  gem 'coffee-rails', '~> 3.2.1'
  gem 'uglifier', '>= 1.0.3'
end



# Use unicorn as the web server
# gem 'unicorn'

# Deploy with Capistrano
# gem 'capistrano'

# To use debugger
# gem 'ruby-debug19', :require => 'ruby-debug'

# install a Javascript runtime for linux

gem "rspec-rails", ">= 2.9.0", :group => [:development, :test]
gem "database_cleaner", ">= 0.6.7", :group => :test 
gem "mongoid-rspec", ">= 1.4.4", :group => :test
gem "factory_girl_rails", ">= 1.2.0", :group => :test
gem "capybara", ">= 1.1.1", :group => :test
gem "launchy", ">= 2.0.5", :group => :test
# case HOST_OS
#   when /darwin/i
#     gem 'rb-fsevent', :group => :development
#     gem 'growl', :group => :development
#   when /linux/i
#     gem 'libnotify', :group => :development
#     gem 'rb-inotify', :group => :development
#   when /mswin|windows/i
#     gem 'rb-fchange', :group => :development
#     gem 'win32console', :group => :development
#     gem 'rb-notifu', :group => :development
# end
group :development do
	gem "guard", ">= 0.6.2"
	gem 'rb-fsevent'
	gem 'growl'

	gem "guard-bundler", ">= 0.1.3"
	gem "guard-rails", ">= 0.0.3"
	gem "guard-livereload", ">= 0.3.0"
	gem "guard-rspec", ">= 0.4.3"
	gem 'pry-rails'
  gem 'debugger'
end

gem "bson_ext", ">= 1.3.1"
gem "mongoid", "~> 2.4.3"
#gem "devise", ">= 1.4.5"
gem 'mongoid_slug', :require => 'mongoid/slug'
gem "mongoid_taggable"
gem "mongoid_taggable_with_context", "~> 0.8.1 "
gem 'mongoid_search'

gem 'devise', "~> 2.0.4 "
gem "omniauth", "~> 1.1.0"
gem 'omniauth-facebook'

#group :production do
#  gem 'therubyracer-heroku', '0.8.1.pre3'
#end

gem "tire"
gem "kaminari"
gem 'spork', '~> 0.9.0.rc'

gem 'less-rails-bootstrap'
gem 'simple_form'

gem 'agent_orange'

gem "thin", :group => :production
