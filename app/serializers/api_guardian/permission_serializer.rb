module ApiGuardian
  class PermissionSerializer < ActiveModel::Serializer
    type 'permissions'

    attributes :id, :name, :desc
  end
end
