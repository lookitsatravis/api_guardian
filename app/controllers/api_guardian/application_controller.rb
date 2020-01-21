# frozen_string_literal: true

module ApiGuardian
  class ApplicationController < ActionController::API
    include ApiGuardian::Concerns::ApiErrors::Handler

    append_before_action :set_current_request

    rescue_from Exception, with: :api_error_handler

    def not_found
      render_not_found
    end

    private

    def set_current_request
      ApiGuardian.current_request = request
    end
  end
end
