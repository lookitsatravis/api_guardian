# frozen_string_literal: true

module ApiGuardian
  class Role < ApplicationRecord
    include ApiGuardian::Concerns::Models::Role
  end
end
