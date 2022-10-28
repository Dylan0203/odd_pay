source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

# Specify your gem's dependencies in odd_pay.gemspec.
gemspec

gem 'money-rails'
gem 'aasm'

group :development do
  gem 'sqlite3'
  gem 'annotate'
end

group :test do
  gem 'shoulda-matchers', '~> 5.0'
end

group :development, :test do
  gem 'rspec-rails'
  gem 'factory_bot_rails'
end

# To use a debugger
# gem 'byebug', group: [:development, :test]
