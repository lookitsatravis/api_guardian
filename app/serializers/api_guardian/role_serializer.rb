# frozen_string_literal: true

module ApiGuardian
  class RoleSerializer < ApiGuardian::Serializers::Base
    set_type 'roles'

    attributes :id, :name, :permissions, :created_at, :updated_at
  end
end
