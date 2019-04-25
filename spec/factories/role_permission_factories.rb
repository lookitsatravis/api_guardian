FactoryBot.define do
  factory :role_permission, class: ApiGuardian::RolePermission do
    association :role, factory: :role
    association :permission, factory: :permission
  end
end
