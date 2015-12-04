module ApiGuardian
  class RolesController < ApiController
    protected

    def includes
      []
    end

    def create_params
      [
        :name, :default
      ]
    end

    def update_params
      create_params
    end
  end
end
