# frozen_string_literal: true

module ApiGuardian
  module Validators
    class PasswordScoreValidator < ActiveModel::Validator
      def validate(record)
        return unless ApiGuardian.configuration.validate_password_score
        min_score = ApiGuardian.configuration.minimum_password_score

        if password_score(record) < min_score
          record.errors[:password] << 'is not strong enough. Consider ' \
            'adding a number, symbols or more letters to make it stronger.'
        end
      end

      private

      # Original from https://github.com/bitzesty/devise_zxcvbn
      def password_score(user)
        password = user.password

        zxcvbn_weak_words = []

        # User method results are saved locally to prevent repeat calls that might be expensive
        if user.respond_to? :email
          local_email = user.email
          zxcvbn_weak_words += [local_email, tokenize_email(local_email)] if local_email
        end

        if user.respond_to? :weak_words
          local_weak_words = user.weak_words
          raise 'weak_words must return an Array' unless local_weak_words.is_a? Array
          zxcvbn_weak_words += local_weak_words
        end

        ApiGuardian.zxcvbn_tester.test(password, zxcvbn_weak_words).score
      end

      def tokenize_email(email)
        email.split(/[[:^word:]_]/)
      end
    end
  end
end
