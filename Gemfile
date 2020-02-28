source 'https://rubygems.org'

gem 'rails','~> 5.2.0'
gem 'puma', '~> 3.12'
gem 'pg', '~> 1.1.0'
gem 'sass-rails', '~> 5.0'
gem 'uglifier', '>= 1.3.0'
gem 'coffee-rails', '~> 4.2'
gem 'jquery-rails', '~> 4.3.1'
gem 'turbolinks',   '~> 5.1.1'
gem 'jbuilder','~> 2.7'
gem 'bcrypt', '~> 3.1.11'
gem 'faker', '~> 1.8.3'
gem 'carrierwave', '~> 1.2.2'
gem 'mini_magick', '~> 4.8.0'
gem 'will_paginate',           '~> 3.1.6'
gem 'bootstrap-will_paginate', '~> 1.0.0'
gem 'bootstrap-sass'
gem 'devise'
gem 'impressionist'
gem 'nokogiri'
gem 'shrine', "~> 2.0"
gem 'image_processing', "~> 1.0"
gem 'fastimage'
gem 'aws-sdk-s3', '~> 1.2'
gem 'sucker_punch'
gem 'content_disposition', '~> 1.0'
gem 'redis', '~> 3.2'
gem 'redis-namespace'

# Not being used on currently active features
gem 'acts-as-taggable-on', '~> 5.0'
gem 'webpush'
gem 'serviceworker-rails'
gem 'ahoy_matey'

group :development, :test, :transfer do
  gem 'dotenv-rails'
end

group :development, :transfer do
  gem 'mysql2'
end

group :development, :test do
  gem 'byebug',  '~> 10.0.2', platforms: [:mri, :mingw, :x64_mingw]
  gem 'rspec-rails', '~> 3.7'
  # Adds support for Capybara system testing and selenium driver
  gem 'capybara', '~> 3.2.1'
  gem 'database_cleaner', '~> 1.7.0'
  gem 'cucumber-rails', '~> 1.6.0', require: false
  gem 'factory_bot_rails', "~> 4.0"
  gem 'selenium-webdriver', "~> 3.142.7"
  gem 'geckodriver-helper'
end

group :development do
  gem 'web-console', '~> 3.6.2'
  gem 'listen',                '~> 3.1.5'
  gem 'spring',                '~> 2.0.2'
  gem 'spring-watcher-listen', '~> 2.0.1'
end

group :test do
  gem 'rails-controller-testing', '~> 1.0.2'
  gem 'minitest-reporters',       '~> 1.3.0'
  gem 'guard',                    '~> 2.16.1'
  gem 'guard-minitest',           '~> 2.4.6'
end

group :production, :transfer do
  gem 'fog-aws'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
