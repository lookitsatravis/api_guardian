# frozen_string_literal: true

module ApiGuardian
  class RolesController < ApiController
    protected

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
