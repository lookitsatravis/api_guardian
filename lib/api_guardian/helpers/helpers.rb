# frozen_string_literal: true

module ApiGuardian
  module Helpers
    def self.email_address?(value)
      # It's not really possible to validate all email addresses for all
      # carriers, so we just check for the one character they all need. Plus,
      # we can know it's not a phone number!
      value && value.include?('@')
    end

    def self.phone_number?(value)
      value && !!value.match(/\+{1}\d+(?!\w)/)
    end
  end
end
