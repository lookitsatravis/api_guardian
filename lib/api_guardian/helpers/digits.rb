require 'uri'
require 'httparty'

module ApiGuardian
  module Helpers
    class Digits
      attr_reader :auth_url, :auth_header

      def initialize(auth_url, auth_header)
        @auth_url = auth_url
        @auth_header = auth_header
      end

      def validate
        # Consider adding additional parameters to the signature to tie your app's own session to the Digits session.
        #   Use the alternate form OAuthEchoHeadersToVerifyCredentialsWithParams: to provide additional parameters to include in
        #   the OAuth service URL. Verify these parameters are present in the service URL and that the API request succeeds.

        validate_oauth_key
        validate_auth_header
        validate_auth_url
        ApiGuardian::ValidationResult.new(true)
      rescue StandardError => e
        ApiGuardian.logger.warn 'Validation failed: ' + e.message
        ApiGuardian::ValidationResult.new(false, e.message)
      end

      def authorize!
        response = HTTParty.get(auth_url, headers: { 'Authorization' => auth_header })
        fail ApiGuardian::Errors::IdentityAuthorizationFailed,
             "Digits API responded with #{response.code}. Expected 200!" unless response.code == 200
        response
      end

      protected

      def validate_oauth_key
        if ApiGuardian.configuration.registration.digits_key.blank?
          fail StandardError,
               'Digits consumer key not set! Please add "config.registration.digits_key" to the ApiGuardian initializer!'
        end
      end

      def validate_auth_header
        auth_header.gsub('OAuth ', '').split(', ').each do |piece|
          key = piece.split('=')[0]
          next unless key == 'oauth_consumer_key'

          value = piece.split('=')[1].delete('"')
          if value != ApiGuardian.configuration.registration.digits_key
            fail StandardError, 'Digits consumer key does not match this request.'
          end
        end
      end

      def validate_auth_url
        domain = URI.parse(auth_url).host
        unless domain.match('api.digits.com')
          fail StandardError, 'Auth url is for invalid domain. Must match "api.digits.com".'
        end
      end
    end
  end
end
