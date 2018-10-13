source 'https://rubygems.org'
source 'https://rails-assets.org' do
  gem 'rails-assets-angucomplete-alt'
end

gem 'angularjs-rails', '~> 1.4', '>= 1.4.7'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 5.1.5'

gem 'pg'


# Use SCSS for stylesheets
gem 'sass-rails'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'

# See https://github.com/rails/execjs#readme for more supported runtimes
# gem 'therubyracer'
gem 'mini_racer'

# Use jquery as the JavaScript library
gem 'jquery-rails'
gem 'jquery-ui-rails'

# Turbolinks is more hassle than it's worth right now
# gem 'turbolinks' '~> 5.x'
# this fixed some turbolinks bugs, but didn't play with angular
# gem 'jquery-turbolinks'

# bundle exec rake doc:rails generates the API under doc/api.
gem 'sdoc', '~> 0.4.0', group: :doc

# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development

group :production do
  gem 'unicorn'
end

group :development do
  # Access an IRB console on exception pages or by using <%= console %> in views
  gem 'web-console'
end

group :development, :test do
  gem 'rspec-rails'             # we need it in develop for it's generators
  gem 'factory_girl_rails'
  gem 'pry'
  gem 'pry-doc'
  gem 'pry-stack_explorer'
end

group :test do
  gem 'capybara'
  gem 'poltergeist'
  gem 'phantomjs', require: 'phantomjs/poltergeist'
end


# Babel JS cross-compiler http://nandovieira.com/using-es2015-with-asset-pipeline-on-ruby-on-rails
# gem 'sprockets', '~> 4.x'
# gem 'sprockets-es6'
# gem 'babel-schmooze-sprockets'
gem 'sprockets'
gem 'sprockets-es6'


# Helpers for Twitter Bootstrap
gem 'bootstrap-sass', '~> 3.3.5'
gem 'bootstrap-toggle-rails'
gem 'sprockets-rails' # , '~> 2.3.2'

gem 'devise'

gem 'redcarpet'

gem 'rails-controller-testing'

gem 'jquery-datatables-rails'
gem 'ajax-datatables-rails'

gem 'actionview-encoded_mail_to'

gem 'webpacker', git: 'https://github.com/rails/webpacker.git' # 4.0.0.pre.3 is not good enough!


