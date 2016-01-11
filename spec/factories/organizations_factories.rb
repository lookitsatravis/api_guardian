FactoryGirl.define do
  factory :organization, class: ApiGuardian::Organization do |f|
    f.sequence(:name) { |n| Faker::Company.name + n.to_s }
    active true
  end
end
