require 'active_support/concern'

# TODO: Break this into further modules to decrease complexity

module ApiGuardian
  module Concerns
    module ApiErrors
      module Handler
        extend ActiveSupport::Concern
        include ApiErrors::Renderer

        included do
          def api_error_handler(exception)
            if exception.is_a? Pundit::NotAuthorizedError
              user_not_authorized
            elsif exception.is_a? ActionController::ParameterMissing
              malformed_request(exception)
            elsif exception.is_a? ActiveRecord::RecordInvalid
              record_invalid(exception)
            elsif exception.is_a? ActiveRecord::RecordNotFound
              render_not_found
            elsif exception.is_a? ApiGuardian::Errors::InvalidContentTypeError
              invalid_content_type
            elsif exception.is_a? ApiGuardian::Errors::InvalidRequestBodyError
              invalid_request_body(exception)
            elsif exception.is_a? ApiGuardian::Errors::InvalidRequestResourceTypeError
              invalid_request_resource_type(exception)
            elsif exception.is_a? ApiGuardian::Errors::InvalidRequestResourceIdError
              invalid_request_resource_id(exception)
            elsif exception.is_a? ApiGuardian::Errors::InvalidUpdateActionError
              invalid_update_action
            elsif exception.is_a? ApiGuardian::Errors::ResetTokenUserMismatchError
              reset_token_mismatch
            elsif exception.is_a? ApiGuardian::Errors::ResetTokenExpiredError
              reset_token_expired
            else
              generic_error_handler(exception)
            end
          end

          def doorkeeper_unauthorized_render_options(_)
            error = construct_error(
              401, 'not_authenticated', 'Not Authenticated',
              'You must be logged in.'
            )
            { json: { errors: [error] } }
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
        end
      end
    end
  end
end
