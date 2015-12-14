module ApiGuardian
  class Identity < ActiveRecord::Base
    belongs_to :user, class_name: ApiGuardian.configuration.user_class.to_s

    validates :provider, presence: true
    validates :provider_uid, presence: true, uniqueness: { scope: :provider, message: 'UID already exists for this provider.' }
  end
end
