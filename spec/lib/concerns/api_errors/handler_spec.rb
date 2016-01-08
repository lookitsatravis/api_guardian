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
        expect { dummy_class.api_error_handler(ActionController::ParameterMissing.new('test')) }.not_to raise_error
      end

      it 'handles ActiveRecord::RecordInvalid' do
      end

      it 'handles ActiveRecord::RecordNotFound' do
        allow_any_instance_of(ActionDispatch::Request).to receive(:original_url).and_return('test.com')
        expect_any_instance_of(Test::Dummy).to receive(:render_error).with(
          404, 'not_found', 'Not Found', 'Resource or endpoint missing: test.com'
        )
        expect { dummy_class.api_error_handler(ActiveRecord::RecordNotFound.new('test')) }.not_to raise_error
      end

      it 'handles InvalidContentTypeError' do
        expect_any_instance_of(Test::Dummy).to receive(:render_error).with(
          415, 'invalid_content_type', 'Invalid Content Type', 'Supported content types are: application/vnd.api+json'
        )
        expect { dummy_class.api_error_handler(ApiGuardian::Errors::InvalidContentTypeError.new('')) }.not_to raise_error
      end

      it 'handles InvalidRequestBodyError' do
        expect_any_instance_of(Test::Dummy).to receive(:render_error).with(
          400, 'invalid_request_body', 'Invalid Request Body', 'The \'test\' property is required.'
        )
        expect { dummy_class.api_error_handler(ApiGuardian::Errors::InvalidRequestBodyError.new('test')) }.not_to raise_error
      end

      it 'handles InvalidRequestResourceTypeError' do
        expect_any_instance_of(Test::Dummy).to receive(:render_error).with(
          400, 'invalid_request_resource_type', 'Invalid Request Resource Type',
          'Expected \'type\' property to be \'test\' for this resource.'
        )
        expect { dummy_class.api_error_handler(ApiGuardian::Errors::InvalidRequestResourceTypeError.new('test')) }.not_to raise_error
      end

      it 'handles InvalidRequestResourceIdError' do
        allow_any_instance_of(ActionController::Parameters).to receive(:fetch).with(:id, nil).and_return('test')
        expect_any_instance_of(Test::Dummy).to receive(:render_error).with(
          400, 'invalid_request_resource_id', 'Invalid Request Resource ID',
          'Request \'id\' property does not match \'id\' of URI. Provided: value, Expected: test'
        )
        expect { dummy_class.api_error_handler(ApiGuardian::Errors::InvalidRequestResourceIdError.new('value')) }.not_to raise_error
      end

      it 'handles InvalidUpdateActionError' do
        expect_any_instance_of(Test::Dummy).to receive(:render_error).with(
          405, 'method_not_allowed', 'Method Not Allowed',
          'Resource update action expects PATCH method.'
        )
        expect { dummy_class.api_error_handler(ApiGuardian::Errors::InvalidUpdateActionError.new('')) }.not_to raise_error
      end

      it 'handles ResetTokenUserMismatchError' do
        expect_any_instance_of(Test::Dummy).to receive(:render_error).with(
          403, 'reset_token_mismatch', 'Reset Token Mismatch',
          'Reset token is not valid for the supplied email address.'
        )
        expect { dummy_class.api_error_handler(ApiGuardian::Errors::ResetTokenUserMismatchError.new('')) }.not_to raise_error
      end

      it 'handles ResetTokenExpiredError' do
        expect_any_instance_of(Test::Dummy).to receive(:render_error).with(
          403, 'reset_token_expired', 'Reset Token Expired',
          'This reset token has expired. Tokens are valid for 24 hours.'
        )
        expect { dummy_class.api_error_handler(ApiGuardian::Errors::ResetTokenExpiredError.new('')) }.not_to raise_error
      end

      it 'handles PasswordRequired' do
        expect_any_instance_of(Test::Dummy).to receive(:render_error).with(
          403, 'password_required', 'Password Required',
          'Password is required for this request.'
        )
        expect { dummy_class.api_error_handler(ApiGuardian::Errors::PasswordRequired.new('')) }.not_to raise_error
      end

      it 'handles PasswordInvalid' do
        expect_any_instance_of(Test::Dummy).to receive(:render_error).with(
          403, 'password_invalid', 'Password Invalid',
          'Password invalid for this request.'
        )
        expect { dummy_class.api_error_handler(ApiGuardian::Errors::PasswordInvalid.new('')) }.not_to raise_error
      end

      it 'handles PhoneNumberInvalid' do
        expect_any_instance_of(Test::Dummy).to receive(:render_error).with(
          422, 'phone_number_invalid', 'Phone Number Invalid',
          'The phone number you provided is invalid.'
        )
        expect { dummy_class.api_error_handler(ApiGuardian::Errors::PhoneNumberInvalid.new('')) }.not_to raise_error
      end

      it 'handles TwoFactorRequired' do
        expect_any_instance_of(Test::Dummy).to receive(:render_error).with(
          402, 'two_factor_required', 'Two-Factor Required',
          'OTP has been sent to the user and must be included in the next' \
          " authentication request in the #{ApiGuardian.configuration.otp_header_name} header."
        )
        expect { dummy_class.api_error_handler(ApiGuardian::Errors::TwoFactorRequired.new('')) }.not_to raise_error
      end

      it 'handles InvalidRegistrationProvider' do
        expect_any_instance_of(Test::Dummy).to receive(:render_error).with(
          400, 'malformed_request', 'Malformed Request', 'test message'
        )
        expect { dummy_class.api_error_handler(ApiGuardian::Errors::InvalidRegistrationProvider.new('test message')) }.not_to raise_error
      end

      it 'handles RegistrationValidationFailed' do
        expect_any_instance_of(Test::Dummy).to receive(:render_error).with(
          422, 'registration_failed', 'Registration Failed', 'test message'
        )
        expect { dummy_class.api_error_handler(ApiGuardian::Errors::RegistrationValidationFailed.new('test message')) }.not_to raise_error
      end

      it 'handles IdentityAuthorizationFailed' do
        expect_any_instance_of(Test::Dummy).to receive(:render_error).with(
          401, 'identity_authorization_failed', 'Identity Authorization Failed', 'test message'
        )
        expect { dummy_class.api_error_handler(ApiGuardian::Errors::IdentityAuthorizationFailed.new('test message')) }.not_to raise_error
      end

      it 'handles IdentityAuthorizationFailed' do
        expect_any_instance_of(Test::Dummy).to receive(:render_error).with(
          400, 'invalid_jwt_secret', 'Invalid JWT Secret', 'test message'
        )
        expect { dummy_class.api_error_handler(ApiGuardian::Errors::InvalidJwtSecret.new('test message')) }.not_to raise_error
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
