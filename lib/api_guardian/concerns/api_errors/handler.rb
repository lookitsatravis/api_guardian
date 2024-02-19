# frozen_string_literal: true

require 'active_support/concern'

# TODO: Break this into further modules to decrease complexity

module ApiGuardian
  module Concerns
    module ApiErrors
      module Handler
        extend ActiveSupport::Concern
        include ApiErrors::Renderer

        included do
          # rubocop:disable Metrics/CyclomaticComplexity
          # rubocop:disable Metrics/MethodLength
          def api_error_handler(exception)
            ApiGuardian.logger.error 'ApiError: ' + exception.class.name + ' - ' + exception.message

            if exception.is_a? Pundit::NotAuthorizedError
              user_not_authorized
            elsif exception.is_a? ActionController::ParameterMissing
              malformed_request(exception)
            elsif exception.is_a? ActiveRecord::RecordInvalid
              record_invalid(exception)
            elsif exception.is_a? ActiveRecord::RecordNotFound
              render_not_found
            elsif exception.is_a? ActiveRecord::RecordNotDestroyed
              render_not_destroyed(exception)
            elsif exception.is_a? ApiGuardian::Errors::InvalidContentType
              invalid_content_type
            elsif exception.is_a? ApiGuardian::Errors::InvalidRequestBody
              invalid_request_body(exception)
            elsif exception.is_a? ApiGuardian::Errors::InvalidRequestResourceType
              invalid_request_resource_type(exception)
            elsif exception.is_a? ApiGuardian::Errors::InvalidRequestResourceId
              invalid_request_resource_id(exception)
            elsif exception.is_a? ApiGuardian::Errors::InvalidUpdateAction
              invalid_update_action
            elsif exception.is_a? ApiGuardian::Errors::ResetTokenUserMismatch
              reset_token_mismatch
            elsif exception.is_a? ApiGuardian::Errors::ResetTokenExpired
              reset_token_expired
            elsif exception.is_a? ApiGuardian::Errors::PasswordRequired
              password_required
            elsif exception.is_a? ApiGuardian::Errors::PasswordInvalid
              password_invalid
            elsif exception.is_a? ApiGuardian::Errors::PhoneNumberInvalid
              phone_number_invalid
            elsif exception.is_a? ApiGuardian::Errors::TwoFactorRequired
              two_factor_required
            elsif exception.is_a? ApiGuardian::Errors::InvalidRegistrationProvider
              malformed_request(exception)
            elsif exception.is_a? ApiGuardian::Errors::RegistrationValidationFailed
              registration_invalid(exception)
            elsif exception.is_a? ApiGuardian::Errors::IdentityAuthorizationFailed
              identity_authorization_failed(exception)
            elsif exception.is_a? ApiGuardian::Errors::InvalidJwtSecret
              invalid_jwt_secret(exception)
            elsif exception.is_a? ApiGuardian::Errors::UserInactive
              user_inactive
            elsif exception.is_a? ApiGuardian::Errors::ResourceStoreMissing
              resource_store_missing(exception)
            elsif exception.is_a? ApiGuardian::Errors::ResourceClassMissing
              resource_class_missing(exception)
            elsif exception.is_a? ApiGuardian::Errors::InvalidAuthenticationProvider
              malformed_request(exception)
            elsif exception.is_a? ApiGuardian::Errors::GuestAuthenticationDisabled
              guest_authentication_disabled
            else
              generic_error_handler(exception)
            end
          end
          # rubocop:enable Metrics/CyclomaticComplexity
          # rubocop:enable Metrics/MethodLength

          def doorkeeper_unauthorized_render_options(_)
            error = construct_error(
              401, 'not_authenticated', 'Not Authenticated',
              'You must be logged in.'
            )
            { json: { errors: [error] } }
          end

          def doorkeeper_forbidden_render_options(_)
            error = construct_error(
              403, 'forbidden', 'Forbidden',
              'You do not have access to this resource.'
            )
            { json: { errors: [error] } }
          end

          def phone_verification_failed
            render_error(
              422, 'phone_verification_failed', 'Phone Verification Failed',
              'The authentication code you provided is invalid or expired.'
            )
          end

          protected

          def user_not_authorized
            render_error(
              403, 'not_authorized', 'Not Authorized',
              'You are not authorized to perform this action.'
            )
          end

          def malformed_request(exception)
            render_error(
              400, 'malformed_request', 'Malformed Request',
              exception.message
            )
          end

          def record_invalid(exception)
            formatted_errors = []
            used_fields = []
            record = exception.record
            record.errors.each do |error|
              next if used_fields.include? error.to_s
              formatted_error = {
                field: error.to_s,
                detail: record.errors[error][0]
              }
              formatted_errors.push formatted_error
              used_fields.push error.to_s
            end
            formatted_errors = formatted_errors.sort_by { |k| k[:field] }
            render_error(422, 'unprocessable_entity', 'Unprocessable Entity', formatted_errors)
          end

          def render_not_found
            render_error(
              404, 'not_found', 'Not Found', 'Resource or endpoint missing: ' +
              request.original_url
            )
          end

          def render_not_destroyed(exception)
            record_invalid(exception)
          end

          def generic_error_handler(exception)
            render_error(500, nil, nil, nil, exception)
          end

          def invalid_content_type
            render_error(
              415, 'invalid_content_type', 'Invalid Content Type',
              'Supported content types are: application/vnd.api+json'
            )
          end

          def invalid_request_body(exception)
            render_error(
              400, 'invalid_request_body', 'Invalid Request Body',
              "The '#{exception.message}' property is required."
            )
          end

          def invalid_request_resource_type(exception)
            render_error(
              400, 'invalid_request_resource_type', 'Invalid Request Resource Type',
              "Expected 'type' property to be '#{exception.message}' for this resource."
            )
          end

          def invalid_request_resource_id(exception)
            render_error(
              400, 'invalid_request_resource_id', 'Invalid Request Resource ID',
              "Request 'id' property does not match 'id' of URI. " \
              "Provided: #{exception.message}, Expected: #{params[:id]}"
            )
          end

          def invalid_update_action
            render_error(
              405, 'method_not_allowed', 'Method Not Allowed',
              'Resource update action expects PATCH method.'
            )
          end

          def reset_token_mismatch
            render_error(
              403, 'reset_token_mismatch', 'Reset Token Mismatch',
              'Reset token is not valid for the supplied email address.'
            )
          end

          def reset_token_expired
            render_error(
              403, 'reset_token_expired', 'Reset Token Expired',
              'This reset token has expired. Tokens are valid for 24 hours.'
            )
          end

          def password_required
            render_error(
              403, 'password_required', 'Password Required',
              'Password is required for this request.'
            )
          end

          def password_invalid
            render_error(
              403, 'password_invalid', 'Password Invalid',
              'Password invalid for this request.'
            )
          end

          def phone_number_invalid
            render_error(
              422, 'phone_number_invalid', 'Phone Number Invalid',
              'The phone number you provided is invalid.'
            )
          end

          def two_factor_required
            render_error(
              402, 'two_factor_required', 'Two-Factor Required',
              'OTP has been sent to the user and must be included in the next' \
              " authentication request in the #{ApiGuardian.configuration.otp_header_name} header."
            )
          end

          def registration_invalid(exception)
            render_error(
              422, 'registration_failed', 'Registration Failed',
              exception.message
            )
          end

          def identity_authorization_failed(exception)
            render_error(
              401, 'identity_authorization_failed', 'Identity Authorization Failed',
              exception.message
            )
          end

          def invalid_jwt_secret(exception)
            render_error(
              400, 'invalid_jwt_secret', 'Invalid JWT Secret',
              exception.message
            )
          end

          def user_inactive
            render_error(
              401, 'user_inactive', 'User Inactive', 'User Inactive'
            )
          end

          def resource_store_missing(exception)
            render_error(
              500, 'resource_store_missing', 'Resource Store Missing',
              exception.message
            )
          end

          def resource_class_missing(exception)
            render_error(
              500, 'resource_class_missing', 'Resource Class Missing',
              exception.message
            )
          end

          def guest_authentication_disabled
            render_error(
              401, 'guest_authentication_disabled', 'Guest Authentication Disabled', 'Guest Authentication Disabled'
            )
          end
        end
      end
    end
  end
end
