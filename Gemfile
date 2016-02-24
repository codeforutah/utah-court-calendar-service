source 'https://rubygems.org'

ruby "2.2.0"

gem 'rails', '4.2.5.1'
gem 'pg', '~> 0.15'
gem 'sass-rails', '~> 5.0'
gem 'uglifier', '>= 1.3.0'
gem 'coffee-rails', '~> 4.1.0'
# See https://github.com/rails/execjs#readme for more supported runtimes
# gem 'therubyracer', platforms: :ruby

gem 'jquery-rails'
gem 'turbolinks'
gem 'jbuilder', '~> 2.0' # https://github.com/rails/jbuilder

gem 'yard', group: :doc # run `bundle exec yard doc` to parse comments and/or `bundle exec yard server` to view documentation at *localhost:8808*

# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use Unicorn as the app server
# gem 'unicorn'

# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development

group :development, :test do
  gem 'pry'
  gem 'rspec-rails', '~> 3.0'
end

group :development do
  gem 'web-console', '~> 2.0'  # Access an IRB console on exception pages or by using <%= console %> in views
  gem 'spring' # # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
end

group :production do
  gem 'rails_12factor'
  gem 'puma'
end

gem 'httparty'
gem 'nokogiri'
