module ApiGuardian
  module Strategies
    module Authentication
      class Digits < Base
        def self.authenticate(user, auth_hash)
          super(user)
          return nil unless user

          identity = ApiGuardian::Stores::UserStore.find_identity_by_provider(user, :digits)
          return nil unless identity

          auth_url, auth_header = parse_digits_data(auth_hash)

          client = ApiGuardian::Helpers::Digits.new(auth_url, auth_header)
          if client.validate.succeeded
            begin
              response = client.authorize!
              update_digits_identity(identity, JSON.parse(response.body))
              return user
            rescue
            end
          end

          nil
        end

        def self.parse_digits_data(auth_hash)
          decoded = Base64.decode64(auth_hash)
          decoded.split(';')
        end

        def self.update_digits_identity(identity, response)
          identity.update_attributes(
            provider_uid: response['id_str'],
            tokens: response['access_token']
          )
        end
      end
    end
  end
end
