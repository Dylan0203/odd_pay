source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

# Specify your gem's dependencies in odd_pay.gemspec.
gemspec

gem 'aasm'
gem 'money-rails'
gem 'pg'
gem 'spgateway_payment_and_invoice_client', github: 'oracle-design/spgateway_payment_and_invoice', tag: '1.0.8'
gem 'hashids'
# Rails 6.1's `rails` meta-gem pulled this in implicitly; Rails 7 dropped that implicit
# dependency, and spec/dummy/config/application.rb requires 'sprockets/railtie' directly.
gem 'sprockets-rails'

group :development do
  gem 'annotate'
  gem 'rails-erd', '> 1.6.1'
  gem 'rubocop', require: false # Linter
  gem 'rubocop-airbnb'
end

group :test do
  gem 'shoulda-matchers', '~> 6.0'
end

group :development, :test do
  gem 'factory_bot_rails'
  gem 'pry-remote'
  gem 'rspec-rails'
  # factory_bot requires 'observer'; Ruby 3.4 removed it from default gems bundled with Ruby.
  gem 'observer'
end

# To use a debugger
# gem 'byebug', group: [:development, :test]
