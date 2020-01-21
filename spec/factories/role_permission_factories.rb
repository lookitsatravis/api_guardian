# frozen_string_literal: true

FactoryBot.define do
  factory :role_permission, class: ApiGuardian::RolePermission do
    association :role, factory: :role
    association :permission, factory: :permission
  end
end
