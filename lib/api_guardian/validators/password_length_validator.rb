# frozen_string_literal: true

module ApiGuardian
  module Validators
    class PasswordLengthValidator < ActiveModel::Validator
      def validate(record)
        min_chars = ApiGuardian.configuration.minimum_password_length
        unless record.password.length >= min_chars
          record.errors[:password] << "Password is too short (minimum is #{min_chars})"
        end
      end
    end
  end
end
