# frozen_string_literal: true

module ApiGuardian
  class Permission < ApplicationRecord
    include ApiGuardian::Concerns::Models::Permission
  end
end
