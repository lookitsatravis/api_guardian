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

      protected

      def otp_email_body(user)
        "<p>Your authentication code is #{user.otp_code}.</p>"
      end
    end
  end
end
