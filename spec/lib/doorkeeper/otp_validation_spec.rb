# frozen_string_literal: true

# Borrowed from
# https://github.com/doorkeeper-gem/doorkeeper/blob/master/spec/lib/oauth/password_access_token_request_spec.rb

module Doorkeeper
  module OAuth
    describe PasswordAccessTokenRequest do
      let(:server) do
        double(
          :server,
          default_scopes: Doorkeeper::OAuth::Scopes.new,
          access_token_expires_in: 2.hours,
          refresh_token_enabled?: false,
          custom_access_token_expires_in: ->(_app) { nil }
        )
      end
      let(:credentials) { Client::Credentials.new(client.uid, client.secret) }
      let(:client) { FactoryBot.create(:application) }
      let(:owner)  { double :owner, id: 99 }

      subject do
        PasswordAccessTokenRequest.new(server, credentials, owner)
      end

      it 'adds otp validation which fails with :invalid_grant' do
        expect(subject).to receive(:validate_otp)

        subject.validate

        expect(subject.error).to be :invalid_grant
      end

      describe 'methods' do
        describe '#validate_otp' do
          it 'validates using Two Factor Authentication' do
            expect(ApiGuardian::Strategies::Authentication::TwoFactor).to(
              receive(:authenticate_request).with(subject.resource_owner, ApiGuardian.current_request)
            )

            subject.validate_otp
          end
        end
      end
    end
  end
end
