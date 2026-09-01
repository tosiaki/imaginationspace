source 'https://rubygems.org'
ruby '3.3.12'

gem 'rails', '~> 8.0.0'
gem 'logger'
gem 'puma'
gem 'pg'
gem 'sass-rails'
gem 'uglifier'
gem 'coffee-rails'
gem 'jquery-rails'
gem 'turbolinks'
gem 'bcrypt'
gem 'faker'
gem 'carrierwave'
gem 'mini_magick'
gem 'will_paginate'
gem 'bootstrap-will_paginate'
gem 'bootstrap-sass'
gem 'devise', '~> 5.0.4'
# gem 'impressionist', '~> 2.0'
gem 'nokogiri'
gem 'shrine'
gem 'image_processing'
gem 'fastimage'
gem 'aws-sdk-s3'
gem 'content_disposition'
gem 'redis'
gem 'redis-namespace'
gem 'webpacker'
gem 'bootsnap'
gem 'rack-cors', '~> 3.0'
gem 'acts-as-taggable-on', '~> 13.0'
gem 'ahoy_matey', '~> 5.5.0'

group :development, :test, :transfer do
  gem 'dotenv-rails'
end

# group :development, :transfer do
  # gem 'mysql2'
# end

group :development, :test do
  # gem 'byebug',  '~> 10.0.2', platforms: [:mri, :mingw, :x64_mingw]
  gem 'rspec-rails', '~> 8.0'
  # Adds support for Capybara system testing and selenium driver
  gem 'capybara', '~> 3.40'
  gem 'database_cleaner', '~> 2.1'
  gem 'cucumber-rails', '~> 4.1', require: false
  gem 'factory_bot_rails', "~> 6.5"
  gem 'selenium-webdriver', "~> 4.48"
  gem 'geckodriver-helper'
end

group :development do
  gem 'web-console', '~> 4.3.0'
  gem 'listen'
  gem 'spring',                '~> 4.7'
  gem 'spring-watcher-listen', '~> 2.1'
end

group :test do
  gem 'rails-controller-testing', '~> 1.0.2'
  gem 'minitest-reporters',       '~> 1.8'
  gem 'guard',                    '~> 2.20'
  gem 'guard-minitest',           '~> 3.0'
end

group :production, :transfer do
  gem 'fog-aws'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
