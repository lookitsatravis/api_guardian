# frozen_string_literal: true

module ApiGuardian
  class RegistrationController < ApiGuardian::ApplicationController
    def create
      @user = user_store.register(register_params)
      render json: @user, status: :created, include: ['role']
    end

    def reset_password
      if user_store.reset_password(reset_password_params)
        head :no_content
      else
        render_not_found
      end
    end

    def complete_reset_password
      if user_store.complete_reset_password(complete_reset_password_params)
        head :no_content
      else
        render_not_found
      end
    end

    protected

    def register_params
      params.require(:type)
      strategy = find_strategy(params.fetch(:type, nil))
      params.permit(:type, *strategy.params)
    end

    def reset_password_params
      params.fetch(:email)
    end

    def complete_reset_password_params
      params.permit(:token, :email, :password, :password_confirmation)
    end

    private

    def find_strategy(provider)
      fail ApiGuardian::Errors::InvalidRegistrationProvider, 'Provider must be a string' unless provider.is_a? String
      ApiGuardian::Strategies::Registration.find_strategy provider
    end

    def user_store
      @user_store ||= ApiGuardian.find_user_store
    end
  end
end
