# frozen_string_literal: true

module ApiGuardian
  class User < ApplicationRecord
    include ApiGuardian::Concerns::Models::User
  end
end
