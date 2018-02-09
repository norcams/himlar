source "https://rubygems.org"

# Versions can be overridden with environment variables for matrix testing.
# Travis will remove Gemfile.lock before installing deps.

group :test do
  gem "rake"
  gem "puppet", ENV['PUPPET_VERSION'] || '~> 4.10.8'
  gem "puppet-syntax"

  gem "puppet-lint"
end
