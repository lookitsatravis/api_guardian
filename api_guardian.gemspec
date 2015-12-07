$:.push File.expand_path('../lib', __FILE__)

# Maintain your gem's version:
require 'api_guardian/version'

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = 'api_guardian'
  s.version     = ApiGuardian::VERSION
  s.authors     = ['Travis Vignon']
  s.email       = ['travis@lookitsatravis.com']
  s.homepage    = 'https://github.com/lookitsatravis/api_guardian'
  s.summary     = 'Drop in authorization and authentication suite for Rails APIs.'
  s.description = 'Drop in authorization and authentication suite for Rails APIs.'
  s.license     = 'MIT'

  s.files = Dir['{app,config,db,lib}/**/*', 'MIT-LICENSE', 'Rakefile', 'README.md']
  s.test_files = Dir['spec/**/*']

  s.required_ruby_version = '>= 2.0.0'

  s.add_dependency 'rails-api', '~> 0.4.0'
  s.add_dependency 'paranoia', '~> 2.0'
  s.add_dependency 'pundit', '~> 1.0.1'
  s.add_dependency 'rack-cors', '~> 0.4.0'
  s.add_dependency 'doorkeeper', '~> 3.0.1'
  s.add_dependency 'doorkeeper-jwt', '~> 0.1.4'
  s.add_dependency 'bcrypt', '~> 3.1.10'
  s.add_dependency 'kaminari', '~> 0.16.3'
  s.add_dependency 'pg', '~> 0.18.4'
  s.add_dependency 'zxcvbn-js', '~> 4.2.0'
  s.add_dependency 'phony', '~> 2.15.10'
  s.add_dependency 'active_model_otp', '~> 1.2.0'
  s.add_dependency 'twilio-ruby', '~> 4.7.0'
  s.add_dependency 'activejob', '~> 4.2.0'
  # s.add_dependency 'active_model_serializers', '0.10.0.rc3'
  s.add_development_dependency 'rspec-rails', '~> 3.4.0'
  s.add_development_dependency 'rspec-activemodel-mocks', '~> 1.0.2'
  s.add_development_dependency 'factory_girl_rails', '~> 4.5.0'
  s.add_development_dependency 'shoulda', '~> 2.11.3'
  s.add_development_dependency 'shoulda-matchers', '~> 3.0.1'
  s.add_development_dependency 'simplecov', '~> 0.11.0'
  s.add_development_dependency 'faker', '~> 1.5.0'
  s.add_development_dependency 'database_cleaner', '~> 1.4.1'
  s.add_development_dependency 'coveralls', '~> 0.8.10'
  s.add_development_dependency 'capybara', '~> 2.5.0'
  s.add_development_dependency 'fuubar', '~> 2.0.0'
  s.add_development_dependency 'rubocop', '~> 0.35.1'
end
