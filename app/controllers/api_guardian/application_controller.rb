module ApiGuardian
  class ApplicationController < ActionController::API
    include ApiGuardian::Concerns::ApiErrors::Handler

    rescue_from Exception, with: :api_error_handler

    def not_found
      render_not_found
    end
  end
end
