# frozen_string_literal: true

require 'active_support/concern'

module ApiGuardian
  module Concerns
    module ApiRequest
      module Validator
        extend ActiveSupport::Concern

        module ClassMethods
          def allowed_content_types
            @allowed_content_types ||= {}
          end

          def allow_content_type(type, options)
            allowed_content_types[type] = options
          end
        end

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
              fail ApiGuardian::Errors::InvalidUpdateAction, request.method
            end
          end

          protected

          def validate_content_type
            if request.body.read != ''
              allowed = determine_content_types

              content_type = request.headers['Content-Type']
              content_type = content_type.split(';').first.to_s if content_type

              unless allowed.include? content_type
                fail ApiGuardian::Errors::InvalidContentType,
                     "Invalid content type #{request.headers['Content-Type']}"
              end
            end
          end

          def determine_content_types
            allowed = ['application/vnd.api+json']

            self.class.allowed_content_types.each do |type, options|
              if options && options[:actions] && options[:actions].include?(action_name.to_sym)
                allowed.push type.split(';').first.to_s
              end
            end

            allowed
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
            fail ApiGuardian::Errors::InvalidRequestBody, 'id' unless top_params.fetch(:id, nil)

            expected_request_id = params[:id]
            request_id = top_params.fetch(:id, nil)

            fail ApiGuardian::Errors::InvalidRequestResourceId,
                 request_id unless request_id == expected_request_id
          end

          def validate_request_type
            top_params = params.fetch(:data)
            fail ApiGuardian::Errors::InvalidRequestBody, 'type' unless top_params.fetch(:type, nil)

            expected_request_type = resource_name.pluralize.underscore.dasherize.gsub(/\//, '-').sub(/^-/, '')

            request_type = top_params.fetch(:type, nil)

            fail ApiGuardian::Errors::InvalidRequestResourceType,
                 expected_request_type unless request_type == expected_request_type
          end
        end
      end
    end
  end
end
