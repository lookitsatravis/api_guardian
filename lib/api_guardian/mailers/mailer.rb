module ApiGuardian
  module Mailers
    class Mailer < ActionMailer::Base
      default from: ApiGuardian.configuration.mail_from_address

      def one_time_password(user)
        @user = user
        mail(
          to: user.email,
          subject: 'Your authentication code.',
          content_type: 'text/html',
          body: otp_email_body(user)
        )
      end

      def reset_password(user)
        @user = user
        mail(
          to: user.email,
          subject: 'Reset your password.',
          content_type: 'text/html',
          body: reset_password_body(user)
        )
      end

      protected

      def otp_email_body(user)
        "<p>Your authentication code is #{user.otp_code}.</p>"
      end

      def reset_password_body(user)
        base_reset_url = ApiGuardian.configuration.client_password_reset_url
        reset_url = "#{base_reset_url}?token=#{user.reset_password_token}&email=#{URI.escape(user.email)}"
        '<p>Hello!</p><p>Please click the following link to reset your password.</p>' \
        "<p><strong><a href='#{reset_url}'>Reset Password Now</a></strong></p>" \
        '<p>If you did not request to reset your password, simply ignore this email' \
        ' and nothing will change.</p><p>Thanks!</p>'
      end
    end
  end
end
