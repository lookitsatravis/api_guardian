# frozen_string_literal: true

FactoryBot.define do
  factory :permission, class: ApiGuardian::Permission do |f|
    f.sequence(:name) { |n| "#{Faker::Lorem.word} #{n}" }
    f.sequence(:desc) { |n| "#{Faker::Lorem.sentence} #{n}" }
  end
end
