require_relative "lib/odd_pay/version"

Gem::Specification.new do |spec|
  spec.name        = "odd_pay"
  spec.version     = OddPay::VERSION
  spec.authors     = ["Dylan Lin"]
  spec.email       = ["dylanmail0203@gmail.com"]
  spec.homepage    = "https://github.com/Dylan0203/odd_pay"
  spec.summary     = "Summary of OddPay."
  spec.description = "Description of OddPay."
  spec.license     = "MIT"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  spec.metadata["allowed_push_host"] = "Set to 'http://mygemserver.com'"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/Dylan0203/odd_pay"
  spec.metadata["changelog_uri"] = "https://github.com/Dylan0203/odd_pay"

  spec.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]

  spec.add_dependency "rails", "~> 6.1.7"
  spec.add_dependency "money-rails"
  spec.add_dependency "aasm"
  spec.add_dependency "pg"
  spec.add_dependency "spgateway_payment_and_invoice_client"
end
