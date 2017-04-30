require 'rest-client'

module ApiGuardian
  module Strategies
    module Authentication
      class Delegation < Base
        provides_authentication_for :delegation

        def authenticate(options)
          delegation_url = ApiGuardian.configuration.delegation_url

          begin
            response = RestClient.post delegation_url, {grant_type: 'email', username: options[:email], password: options[:password]}

            unless response.code == 200
              fail(
                ApiGuardian::Errors::IdentityAuthorizationFailed,
                'The delegation strategy failed with response code ' + response.code
              )
            end
          rescue RestClient::ExceptionWithResponse => e
            fail(
              ApiGuardian::Errors::IdentityAuthorizationFailed,
              'The delegation strategy failed with the response ' + response
            )
          end
        end
      end
    end
  end
end
