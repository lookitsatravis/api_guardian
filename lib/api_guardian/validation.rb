# frozen_string_literal: true

module ApiGuardian
  class ValidationResult
    attr_reader :succeeded, :error

    def initialize(succeeded = true, error = '')
      @succeeded = succeeded
      @error = error
    end
  end
end
