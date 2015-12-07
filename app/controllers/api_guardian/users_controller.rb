module ApiGuardian
  class UsersController < ApiController
    protected

    def includes
      ['role']
    end

    def create_params
      [:first_name, :last_name, :email, :role_id, :password, :password_confirmation]
    end

    def update_params
      create_params
    end
  end
end
