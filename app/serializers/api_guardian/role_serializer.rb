module ApiGuardian
  class RoleSerializer < ActiveModel::Serializer
    type 'roles'

    attributes :id, :name, :permissions, :created_at, :updated_at
  end
end
