source 'https://rubygems.org'
ruby '2.7.2'

gem 'rails', '~> 6.1'
gem 'puma'
gem 'pg'
gem 'sass-rails'
gem 'uglifier'
gem 'coffee-rails'
gem 'jquery-rails'
gem 'turbolinks'
gem 'jbuilder'
gem 'bcrypt'
gem 'faker'
gem 'carrierwave'
gem 'mini_magick'
gem 'will_paginate'
gem 'bootstrap-will_paginate'
gem 'bootstrap-sass'
gem 'devise'
gem 'impressionist'
gem 'nokogiri'
gem 'shrine'
gem 'image_processing'
gem 'fastimage'
gem 'aws-sdk-s3'
gem 'sucker_punch'
gem 'content_disposition'
gem 'redis'
gem 'redis-namespace'
gem 'webpacker'
gem 'bootsnap'

# Not being used on currently active features
gem 'acts-as-taggable-on', '~> 5.0'
gem 'webpush'
gem 'serviceworker-rails'
gem 'ahoy_matey'

group :development, :test, :transfer do
  gem 'dotenv-rails'
end

# group :development, :transfer do
  # gem 'mysql2'
# end

group :development, :test do
  gem 'byebug',  '~> 10.0.2', platforms: [:mri, :mingw, :x64_mingw]
  gem 'rspec-rails', '~> 3.7'
  # Adds support for Capybara system testing and selenium driver
  gem 'capybara', '~> 3.2.1'
  gem 'database_cleaner', '~> 1.7.0'
  gem 'cucumber-rails', '~> 2.3.0', require: false
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
