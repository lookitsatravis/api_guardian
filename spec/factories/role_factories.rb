# frozen_string_literal: true

FactoryBot.define do
  factory :role, class: ApiGuardian::Role do |f|
    f.sequence(:name) { |n| Faker::Lorem.word + n.to_s }
    f.default { false }

    factory :default_role do
      default { true }
    end

    factory :role_with_permissions do
      transient do
        permission_count { 5 }
      end

      after(:create) do |role, evaluator|
        evaluator.permission_count.times do |n|
          permission = create(:permission)
          granted = n.even? ? true : false
          create(:role_permission, role: role, permission: permission, granted: granted)
        end
      end
    end
  end
end
