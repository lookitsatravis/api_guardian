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

  s.required_ruby_version = '>= 2.2.2'

  s.add_dependency 'rails', '>= 5.0', '< 6.0'
  s.add_dependency 'active_model_otp', '~> 1.2'
  s.add_dependency 'bcrypt', '~> 3.1'
  s.add_dependency 'doorkeeper-grants_assertion', '~> 0.0.1'
  s.add_dependency 'doorkeeper-jwt', '~> 0.1'
  s.add_dependency 'doorkeeper', '~> 4.2'
  s.add_dependency 'fast_jsonapi', '~> 1.5'
  s.add_dependency 'kaminari', '~> 1.1.1'
  s.add_dependency 'koala', '~> 2.5'
  s.add_dependency 'paranoia', '~> 2.3'
  s.add_dependency 'pg', '~> 0.18'
  s.add_dependency 'phony', '~> 2.15'
  s.add_dependency 'pundit', '~> 1.1'
  s.add_dependency 'rack-cors', '~> 0.4'
  s.add_dependency 'zxcvbn-js', '~> 4.2'
  s.add_development_dependency 'database_cleaner', '~> 1.7'
  s.add_development_dependency 'factory_bot_rails', '~> 5.0'
  s.add_development_dependency 'faker', '~> 1.9'
  s.add_development_dependency 'fuubar', '~> 2.3'
  s.add_development_dependency 'generator_spec', '~> 0.9'
  s.add_development_dependency 'rspec-activemodel-mocks', '~> 1.1'
  s.add_development_dependency 'rspec-rails', '~> 3.8'
  s.add_development_dependency 'rubocop', '~> 0.67'
  s.add_development_dependency 'rubocop-performance', '~> 1.1'
  s.add_development_dependency 'shoulda-matchers', '~> 4.0'
  s.add_development_dependency 'simplecov', '~> 0.16'
  s.add_development_dependency 'webmock', '~> 3.5'
end
