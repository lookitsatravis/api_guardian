require 'active_support/concern'

module ApiGuardian
  module Concerns
    module ApiRequest
      module Validator
        extend ActiveSupport::Concern

        included do
          def validate_api_request
            validate_content_type

            # Make sure we conform to json-api request spec
            case request.method
            when 'POST'
              validate_post_request
            when 'PATCH'
              validate_patch_request
            end

            if action_name == 'update' && request.method != 'PATCH'
              fail ApiGuardian::Errors::InvalidUpdateActionError, request.method
            end
          end

          protected

          def validate_content_type
            if request.body.read != '' && request.headers['Content-Type'] != 'application/vnd.api+json'
              fail ApiGuardian::Errors::InvalidContentTypeError, "Invalid content type #{request.headers['Content-Type']}"
            end
          end

          def validate_post_request
            validate_request_type
          end

          def validate_patch_request
            validate_request_id
            validate_request_type
          end

          def validate_request_id
            top_params = params.fetch(:data)
            fail ApiGuardian::Errors::InvalidRequestBodyError, 'id' unless top_params.fetch(:id, nil)

            expected_request_id = params[:id]
            request_id = top_params.fetch(:id, nil)

            fail ApiGuardian::Errors::InvalidRequestResourceIdError, request_id unless request_id == expected_request_id
          end

          def validate_request_type
            top_params = params.fetch(:data)
            fail ApiGuardian::Errors::InvalidRequestBodyError, 'type' unless top_params.fetch(:type, nil)

            expected_request_type = resource_name.pluralize.downcase
            request_type = top_params.fetch(:type, nil)

            fail ApiGuardian::Errors::InvalidRequestResourceTypeError, expected_request_type unless request_type == expected_request_type
          end
        end
      end
    end
  end
end
