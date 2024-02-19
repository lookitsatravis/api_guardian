# frozen_string_literal: true

module ApiGuardian
  class Identity < ApplicationRecord
    include ApiGuardian::Concerns::Models::Identity
  end
end
