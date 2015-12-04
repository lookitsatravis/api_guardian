module ApiGuardian
  class RegistrationController < ApiGuardian::ApplicationController
    def create
      @user = ApiGuardian::Stores::UserStore.register(register_params)
      render json: @user, status: :created, include: ['role']
    end

    def reset_password
      if ApiGuardian::Stores::UserStore.reset_password(reset_password_params)
        head :no_content
      else
        render_not_found
      end
    end

    def complete_reset_password
      if ApiGuardian::Stores::UserStore.complete_reset_password(complete_reset_password_params)
        head :no_content
      else
        render_not_found
      end
    end

    protected

    def register_params
      params.permit(:email, :password, :password_confirmation)
    end

    def reset_password_params
      params.fetch(:email)
    end

    def complete_reset_password_params
      params.permit(:token, :email, :password, :password_confirmation)
    end
  end
end
