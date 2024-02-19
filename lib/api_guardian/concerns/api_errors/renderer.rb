# frozen_string_literal: true

require 'active_support/concern'

module ApiGuardian
  module Concerns
    module ApiErrors
      module Renderer
        extend ActiveSupport::Concern

        included do
          def render_error(status, code, title, detail, exception = nil)
            error = construct_error status, code, title, detail
            if Rails.env.production?
              render json: { errors: [error] }, status: status
            else
              non_production_render error, exception, status
            end
          end

          protected

          def construct_error(status, code, title, detail)
            # TODO: Create error log here
            {
              id: SecureRandom.uuid,
              code: code || 'unknown',
              status: status.to_s || '500',
              title: title || 'Unknown',
              detail: detail || 'An unknown error has occurred and has been logged.'
            }
          end

          def non_production_render(error, exception, status)
            if exception
              render json: { errors: [error], exception: exception.class.name,
                             message: exception.message, trace: exception.backtrace[0, 10] },
                     status: status
            else
              render json: { errors: [error] }, status: status
            end
          end

          def render(**_)
            return super if defined?(super)
          end
        end
      end
    end
  end
end
