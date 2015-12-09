module ApiGuardian
  module Jobs
    class SendOtp < ActiveJob::Base
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
          Rails.logger.info '[ApiGuardian] User will provide code from Google Auth app'
        else
          Rails.logger.error "[ApiGuardian] No valid OTP send methods for user #{user.id}!"
        end
      end

      private

      def send_sms(user, force)
        # We force the message if the user is trying to verify their phone
        return unless force || user_can_receive_sms?(user)

        body = "#{user.otp_code} is your authentication code."

        ApiGuardian.twilio_client.messages.create(
          from: ApiGuardian.configuration.twilio_send_from,
          to: user.phone_number,
          body: body
        )
      rescue StandardError => e
        Rails.logger.warn "[ApiGuardian] Could not connect to Twilio! #{e.message}"
      end

      def send_voice(user, force)
        # We force the message if the user is trying to verify their phone
        return unless force || user_can_receive_sms?(user)

        ApiGuardian.twilio_client.calls.create(
          from: ApiGuardian.configuration.twilio_send_from,
          to: user.phone_number,
          url: ApiGuardian::Engine.routes.url_helpers.voice_otp_user_url(user)
        )
      rescue StandardError => e
        Rails.logger.warn "[ApiGuardian] Could not connect to Twilio! #{e.message}"
      end

      def send_email(user)
        mailer = ApiGuardian::Mailers::Mailer
        mailer.one_time_password(user).deliver_later
      end

      def user_can_receive_sms?(user)
        unless user.phone_number.present? && user.phone_number_confirmed_at.present?
          Rails.logger.error '[ApiGuardian] User does not have a confirmed phone number! Cannot send OTP.'
          return false
        end
        true
      end
    end
  end
end
