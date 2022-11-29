source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

# Specify your gem's dependencies in odd_pay.gemspec.
gemspec

gem 'aasm'
gem 'money-rails'
gem 'pg'
# gem 'spgateway_payment_and_invoice_client', github: 'oracle-design/spgateway_payment_and_invoice', branch: 'master'
gem 'spgateway_payment_and_invoice_client', path: '../../spgateway_payment_and_invoice'
gem 'hashids'

group :development do
  gem 'annotate'
  gem 'rails-erd', '> 1.6.1'
  gem 'rubocop', require: false # Linter
  gem 'rubocop-airbnb'
end

group :test do
  gem 'shoulda-matchers', '~> 5.0'
end

group :development, :test do
  gem 'factory_bot_rails'
  gem 'pry-remote'
  gem 'rspec-rails'
end

# To use a debugger
# gem 'byebug', group: [:development, :test]
