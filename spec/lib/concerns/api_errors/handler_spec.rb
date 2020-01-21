# frozen_string_literal: true

module Test
  class Dummy
    include ControllerConcernTestHelpers
    include ApiGuardian::Concerns::ApiErrors::Handler
  end
end

describe ApiGuardian::Concerns::ApiErrors::Handler, type: :request do
  let(:dummy_class) { Test::Dummy.new }

  # Methods
  describe 'methods' do
    describe '#doorkeeper_unauthorized_render_options' do
      it 'returns an error hash' do
        expect_any_instance_of(Test::Dummy).to receive(:construct_error).with(
          401, 'not_authenticated', 'Not Authenticated', 'You must be logged in.'
        ).and_return('foo')
        result = dummy_class.doorkeeper_unauthorized_render_options ''

        expect(result).to eq(json: { errors: ['foo'] })
      end
    end

    describe '#api_error_handler' do
      it 'handles Pundit::NotAuthorizedError' do
        expect_any_instance_of(Test::Dummy).to receive(:render_error).with(
          403, 'not_authorized', 'Not Authorized', 'You are not authorized to perform this action.'
        )
        expect { dummy_class.api_error_handler(Pundit::NotAuthorizedError.new) }.not_to raise_error
      end

      it 'handles ActionController::ParameterMissing' do
        expect_any_instance_of(Test::Dummy).to receive(:render_error).with(
          400, 'malformed_request', 'Malformed Request', 'param is missing or the value is empty: test'
        )
        expect do
          dummy_class.api_error_handler(ActionController::ParameterMissing.new('test'))
        end.not_to raise_error
      end

      it 'handles ActiveRecord::RecordInvalid' do
      end

      it 'handles ActiveRecord::RecordNotFound' do
        allow_any_instance_of(ActionDispatch::Request).to receive(:original_url).and_return('test.com')
        expect_any_instance_of(Test::Dummy).to receive(:render_error).with(
          404, 'not_found', 'Not Found', 'Resource or endpoint missing: test.com'
        )
        expect do
          dummy_class.api_error_handler(ActiveRecord::RecordNotFound.new('test'))
        end.not_to raise_error
      end

      it 'handles ActiveRecord::RecordNotDestroyed' do
      end

      it 'handles InvalidContentType' do
        expect_any_instance_of(Test::Dummy).to receive(:render_error).with(
          415, 'invalid_content_type', 'Invalid Content Type', 'Supported content types are: application/vnd.api+json'
        )
        expect do
          dummy_class.api_error_handler(ApiGuardian::Errors::InvalidContentType.new(''))
        end.not_to raise_error
      end

      it 'handles InvalidRequestBody' do
        expect_any_instance_of(Test::Dummy).to receive(:render_error).with(
          400, 'invalid_request_body', 'Invalid Request Body', 'The \'test\' property is required.'
        )
        expect do
          dummy_class.api_error_handler(ApiGuardian::Errors::InvalidRequestBody.new('test'))
        end.not_to raise_error
      end

      it 'handles InvalidRequestResourceType' do
        expect_any_instance_of(Test::Dummy).to receive(:render_error).with(
          400, 'invalid_request_resource_type', 'Invalid Request Resource Type',
          'Expected \'type\' property to be \'test\' for this resource.'
        )
        expect do
          dummy_class.api_error_handler(ApiGuardian::Errors::InvalidRequestResourceType.new('test'))
        end.not_to raise_error
      end

      it 'handles InvalidRequestResourceId' do
        allow_any_instance_of(ActionController::Parameters).to receive(:fetch).with(:id, nil).and_return('test')
        expect_any_instance_of(Test::Dummy).to receive(:render_error).with(
          400, 'invalid_request_resource_id', 'Invalid Request Resource ID',
          'Request \'id\' property does not match \'id\' of URI. Provided: value, Expected: test'
        )
        expect do
          dummy_class.api_error_handler(ApiGuardian::Errors::InvalidRequestResourceId.new('value'))
        end.not_to raise_error
      end

      it 'handles InvalidUpdateAction' do
        expect_any_instance_of(Test::Dummy).to receive(:render_error).with(
          405, 'method_not_allowed', 'Method Not Allowed',
          'Resource update action expects PATCH method.'
        )
        expect do
          dummy_class.api_error_handler(ApiGuardian::Errors::InvalidUpdateAction.new(''))
        end.not_to raise_error
      end

      it 'handles ResetTokenUserMismatch' do
        expect_any_instance_of(Test::Dummy).to receive(:render_error).with(
          403, 'reset_token_mismatch', 'Reset Token Mismatch',
          'Reset token is not valid for the supplied email address.'
        )
        expect do
          dummy_class.api_error_handler(ApiGuardian::Errors::ResetTokenUserMismatch.new(''))
        end.not_to raise_error
      end

      it 'handles ResetTokenExpired' do
        expect_any_instance_of(Test::Dummy).to receive(:render_error).with(
          403, 'reset_token_expired', 'Reset Token Expired',
          'This reset token has expired. Tokens are valid for 24 hours.'
        )
        expect do
          dummy_class.api_error_handler(ApiGuardian::Errors::ResetTokenExpired.new(''))
        end.not_to raise_error
      end

      it 'handles PasswordRequired' do
        expect_any_instance_of(Test::Dummy).to receive(:render_error).with(
          403, 'password_required', 'Password Required',
          'Password is required for this request.'
        )
        expect do
          dummy_class.api_error_handler(ApiGuardian::Errors::PasswordRequired.new(''))
        end.not_to raise_error
      end

      it 'handles PasswordInvalid' do
        expect_any_instance_of(Test::Dummy).to receive(:render_error).with(
          403, 'password_invalid', 'Password Invalid',
          'Password invalid for this request.'
        )
        expect do
          dummy_class.api_error_handler(ApiGuardian::Errors::PasswordInvalid.new(''))
        end.not_to raise_error
      end

      it 'handles PhoneNumberInvalid' do
        expect_any_instance_of(Test::Dummy).to receive(:render_error).with(
          422, 'phone_number_invalid', 'Phone Number Invalid',
          'The phone number you provided is invalid.'
        )
        expect do
          dummy_class.api_error_handler(ApiGuardian::Errors::PhoneNumberInvalid.new(''))
        end.not_to raise_error
      end

      it 'handles TwoFactorRequired' do
        expect_any_instance_of(Test::Dummy).to receive(:render_error).with(
          402, 'two_factor_required', 'Two-Factor Required',
          'OTP has been sent to the user and must be included in the next' \
          " authentication request in the #{ApiGuardian.configuration.otp_header_name} header."
        )
        expect do
          dummy_class.api_error_handler(ApiGuardian::Errors::TwoFactorRequired.new(''))
        end.not_to raise_error
      end

      it 'handles InvalidRegistrationProvider' do
        expect_any_instance_of(Test::Dummy).to receive(:render_error).with(
          400, 'malformed_request', 'Malformed Request', 'test message'
        )
        expect do
          dummy_class.api_error_handler(ApiGuardian::Errors::InvalidRegistrationProvider.new('test message'))
        end.not_to raise_error
      end

      it 'handles RegistrationValidationFailed' do
        expect_any_instance_of(Test::Dummy).to receive(:render_error).with(
          422, 'registration_failed', 'Registration Failed', 'test message'
        )
        expect do
          dummy_class.api_error_handler(ApiGuardian::Errors::RegistrationValidationFailed.new('test message'))
        end.not_to raise_error
      end

      it 'handles IdentityAuthorizationFailed' do
        expect_any_instance_of(Test::Dummy).to receive(:render_error).with(
          401, 'identity_authorization_failed', 'Identity Authorization Failed', 'test message'
        )
        expect do
          dummy_class.api_error_handler(ApiGuardian::Errors::IdentityAuthorizationFailed.new('test message'))
        end.not_to raise_error
      end

      it 'handles InvalidJwtSecret' do
        expect_any_instance_of(Test::Dummy).to receive(:render_error).with(
          400, 'invalid_jwt_secret', 'Invalid JWT Secret', 'test message'
        )
        expect do
          dummy_class.api_error_handler(ApiGuardian::Errors::InvalidJwtSecret.new('test message'))
        end.not_to raise_error
      end

      it 'handles UserInactive' do
        expect_any_instance_of(Test::Dummy).to receive(:render_error).with(
          401, 'user_inactive', 'User Inactive', 'User Inactive'
        )
        expect do
          dummy_class.api_error_handler(ApiGuardian::Errors::UserInactive.new('test message'))
        end.not_to raise_error
      end

      it 'handles ResourceStoreMissing' do
        expect_any_instance_of(Test::Dummy).to receive(:render_error).with(
          500, 'resource_store_missing', 'Resource Store Missing', 'test message'
        )
        expect do
          dummy_class.api_error_handler(ApiGuardian::Errors::ResourceStoreMissing.new('test message'))
        end.not_to raise_error
      end

      it 'handles ResourceClassMissing' do
        expect_any_instance_of(Test::Dummy).to receive(:render_error).with(
          500, 'resource_class_missing', 'Resource Class Missing', 'test message'
        )
        expect do
          dummy_class.api_error_handler(ApiGuardian::Errors::ResourceClassMissing.new('test message'))
        end.not_to raise_error
      end

      it 'handles GuestAuthenticationDisabled' do
        expect_any_instance_of(Test::Dummy).to receive(:render_error).with(
          401, 'guest_authentication_disabled', 'Guest Authentication Disabled', 'Guest Authentication Disabled'
        )
        expect do
          dummy_class.api_error_handler(ApiGuardian::Errors::GuestAuthenticationDisabled.new('test message'))
        end.not_to raise_error
      end

      it 'handles generic errors' do
        exception = StandardError.new('')
        expect_any_instance_of(Test::Dummy).to receive(:render_error).with(
          500, nil, nil, nil, exception
        )
        expect { dummy_class.api_error_handler(exception) }.not_to raise_error
      end
    end

    describe '#phone_verification_failed' do
      it 'handles TwoFactorRequired' do
        expect_any_instance_of(Test::Dummy).to receive(:render_error).with(
          422, 'phone_verification_failed', 'Phone Verification Failed',
          'The authentication code you provided is invalid or expired.'
        )
        expect { dummy_class.phone_verification_failed }.not_to raise_error
      end
    end
  end
end
