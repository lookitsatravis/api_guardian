# frozen_string_literal: true

module ApiGuardian
  module Jobs
    class SendOtp < ApplicationJob
      queue_as :default

      def perform(user, force = false)
        return unless user.otp_enabled?
        send_otp(user, force)
      end

      def send_otp(user, force)
        case user.otp_method
        when 'sms'
          send_sms(user, force)
        when 'voice'
          send_voice(user, force)
        when 'email'
          send_email(user)
        when 'google_auth'
          ApiGuardian.logger.info 'User will provide code from Google Auth app'
        else
          ApiGuardian.logger.error "No valid OTP send methods for user #{user.id}!"
        end
      end

      private

      def send_sms(user, force)
        # We force the message if the user is trying to verify their phone
        return unless force || user_can_receive_sms?(user)

        ApiGuardian.configuration.on_send_otp_via_sms.call(user)
      end

      def send_voice(user, force)
        # We force the message if the user is trying to verify their phone
        return unless force || user_can_receive_sms?(user)

        ApiGuardian.configuration.on_send_otp_via_voice.call(user)
      end

      def send_email(user)
        ApiGuardian.configuration.on_send_otp_via_email.call(user)
      end

      def user_can_receive_sms?(user)
        unless user.phone_number.present? && user.phone_number_confirmed_at.present?
          ApiGuardian.logger.error 'User does not have a confirmed phone number! Cannot send OTP.'
          return false
        end
        true
      end
    end
  end
end
