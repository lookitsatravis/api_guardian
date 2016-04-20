
module ApiGuardian
  module Strategies
    module Registration
      class Digits < Base
        provides_registration_for :digits

        add_config_option :digits_key

        allowed_api_parameters :auth_url, :auth_header

        def validate(attributes)
          digits_client(attributes).validate
        end

        def register(store, attributes)
          super(attributes)

          response = digits_client(attributes).authorize!

          data = build_user_attributes_from_response(JSON.parse(response.body))
          identity_data = build_identity_attributes_from_response(JSON.parse(response.body))

          # create user
          instance = store.new(nil)
          user = instance.create_with_identity(data, identity_data, confirm_email: false)

          # TODO: put user created event onto queue

          user
        end

        def build_user_attributes_from_response(response)
          password = SecureRandom.hex(32)

          {
            phone_number: response['phone_number'],
            phone_number_confirmed_at: DateTime.now.utc,
            role_id: ApiGuardian::Stores::RoleStore.default_role.id,
            active: true,
            password: password,
            password_confirmation: password
          }
        end

        def build_identity_attributes_from_response(response)
          {
            provider: 'digits',
            provider_uid: response['id_str'],
            tokens: response['access_token']
          }
        end

        protected

        def digits_client(attributes)
          @digits_client ||= ApiGuardian::Helpers::Digits.new(attributes[:auth_url], attributes[:auth_header])
        end
      end
    end
  end
end
