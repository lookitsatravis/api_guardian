# frozen_string_literal: true

module ApiGuardian
  module Strategies
    module Registration
      class Base
        class << self
          def allowed_api_parameters(*args)
            args.each do |a|
              params.push a
            end
          end

          def params
            @params ||= []
          end

          def add_config_option(key)
            ApiGuardian.configuration.registration.add_config_option key
          end

          def providers
            @@providers ||= {}
          end

          def provides_registration_for(provider)
            providers[provider.to_sym] = new
          end
        end

        def validate(_attributes)
          ApiGuardian::ValidationResult.new(true)
        end

        def register(attributes)
          validation = validate(attributes)
          unless validation.succeeded
            fail ApiGuardian::Errors::RegistrationValidationFailed, validation.error
          end
        end

        def params
          self.class.params
        end

        def prep_passwords(attributes)
          password = attributes[:password]
          password_confirmation = attributes[:password_confirmation]

          unless password && password_confirmation
            password = password_confirmation = SecureRandom.hex(32)
          end

          [password, password_confirmation]
        end
      end
    end
  end
end
