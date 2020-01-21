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

      it 'adds jwt validation which fails with :invalid_grant' do
        expect(subject).to receive(:validate_jwt_secret)

        subject.validate

        expect(subject.error).to be :invalid_grant
      end

      describe 'methods' do
        describe '#validate_jwt_secret' do
          it 'validates JWT Secret' do
            expect_any_instance_of(ApiGuardian::Configuration).to(
              receive(:jwt_secret).and_return(nil)
            )

            expect { subject.validate_jwt_secret }.to(
              raise_error(ApiGuardian::Errors::InvalidJwtSecret)
            )

            expect_any_instance_of(ApiGuardian::Configuration).to(
              receive(:jwt_secret).and_return('changeme')
            )

            expect { subject.validate_jwt_secret }.to(
              raise_error(ApiGuardian::Errors::InvalidJwtSecret)
            )

            expect_any_instance_of(ApiGuardian::Configuration).to(
              receive(:jwt_secret).and_return('valid')
            )

            expect { subject.validate_jwt_secret }.not_to raise_error
          end
        end
      end
    end
  end
end
