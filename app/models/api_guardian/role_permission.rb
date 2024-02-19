# frozen_string_literal: true

module ApiGuardian
  class RolePermission < ApplicationRecord
    include ApiGuardian::Concerns::Models::RolePermission
  end
end
