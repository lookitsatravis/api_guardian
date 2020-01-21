# frozen_string_literal: true

module ApiGuardian
  class UserSerializer < ApiGuardian::Serializers::Base
    set_type 'users'

    attributes :id, :first_name, :last_name, :email, :email_confirmed_at,
               :phone_number, :phone_number_confirmed_at, :created_at, :updated_at

    attribute :guest?, key: :is_guest

    belongs_to :role
  end
end
