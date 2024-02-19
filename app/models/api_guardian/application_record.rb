# frozen_string_literal: true

module ApiGuardian
  class ApplicationRecord < ActiveRecord::Base
    self.abstract_class = true
  end
end
