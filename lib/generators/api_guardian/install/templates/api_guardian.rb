ApiGuardian.configure do |config|
  # In order to change the base user class, you'd need to uncomment this line and
  # enter your own class name. Your class will need to include the
  # ApiGuardian::Concerns::Models::User module.
  # config.user_class = 'User'

  # Change the minimum password length to set a user's password. Default is 8 add
  # it is recommended that it not be any lower.
  # config.minimum_password_length = 8

  # config.minimum_password_score = 4

  # Enable two-factor authentication
  # config.enable_2fa = true

  # Methods for sending the 2FA one-time password. Note: it is not recommended
  # that 2FA codes be sent through email.
  # config.available_2fa_methods = %w(sms voice google_auth email)

  # Allow anonymous user authentication
  # config.allow_guest_authentication = true

  # 2FA header name. This header is used to validate a OTP and can be customized
  # to have the app name, for example.
  # config.otp_header_name = 'AG-2FA-TOKEN'

  # Access token expiration time (default 2 hours).
  # config.access_token_expires_in = 2.hours

  # WWW-Authenticate Realm (default 'ApiGuardian').
  # config.realm = 'My Application'

  # JSON Web Tokens are used as the OAuth2 access token. Generating the JWT can
  # be configured in the following ways:
  #
  # The JWT issuer can be configured. The default is 'api_guardian_' with the
  # current version of ApiGuardian appended.
  # config.jwt_issuer = 'my_app'
  #
  # The JWT secret can be customized to improve security of the JWT payload. By
  # default, a simple secret token is used. But, if you're using RS* encoding, you
  # must specify the path to your secret key.
  # config.jwt_secret = 'changeme'
  # config.jwt_secret_key_path = 'path/to/file.pem'
  #
  # The Encryption Method can use any of the valid methods found in
  # https://github.com/jwt/ruby-jwt. The default is HMAC 256.
  # config.jwt_encryption_method = :hs256

  # The json_api response keyword separator
  # https://github.com/Netflix/fast_jsonapi#key-transforms
  # config.json_api_key_transform = :dash

  # The Client Password Reset URL is used in the email sent when resetting
  # a user's password. The client should post the token provided along with the
  # users's new password to /complete-reset-password. This is done because this
  # library is meant to be used on API-Only Rails apps which means there is no
  # internal route for the user to reset their password, and the functionality
  # must be provided by the client.
  # config.client_password_reset_url = 'https://myapp.com'

  # You can use this block to hook into what happens after a user's password
  # reset is initiated. `reset_url` will be provided and can be used to customize
  # an email sent to the user.
  # config.on_reset_password = lambda do |user, reset_url|
  #   MyMailer.reset_password(user).deliver_later
  # end

  # You can use this block to hook into what happens after a user's password
  # reset is completed. You might use this to notify the user that a reset
  # has happened.
  # config.on_reset_password_complete = lambda do |user|
  #   MyMailer.reset_password_complete(user).deliver_later
  # end

  # When a user's password is updated, you might use this to notify the user that
  # the change has happened.
  # config.on_password_changed = lambda do |user|
  #   MyMailer.password_changed(user).deliver_later
  # end

  # Often, applications will want to send emails or do other things specific to
  # registration. You can use this block to hook into what happens after a user is
  # registered.
  # config.after_user_registered = lambda do |user|
  #   MyMailer.welcome(user).deliver_later
  # end

  # You can use this block to hook into the login lifecycle.
  # config.on_login_success = lambda do |user|
  #   UserStore.track_login user
  # end
  #
  # config.on_login_failure = lambda do |provider, options|
  #   AnalyticsService.log_failed_login provider, options
  # end

  # You can use this block to hook into what happens when a one-time password token
  # needs to be sent via SMS. This allows you to use any provider for sending the SMS.
  # config.on_send_otp_via_sms = lambda do |user|
  #   # Example using Twilio - twilio-ruby
  #   twilio_send_from_number = '+15551234567'
  #   twilio_client = Twilio::REST::Client.new twilio_id, twilio_token
  #   twilio_client.messages.create(
  #     from: twilio_send_from_number,
  #     to: user.phone_number,
  #     body: "#{user.otp_code} is your authentication code."
  #   )
  # end

  # You can use this block to hook into what happens when a one-time password token
  # needs to be sent via voice. This allows you to use any provider for sending the voice
  # call.
  # config.on_send_otp_via_voice = lambda do |user|
  #   # Example using Twilio - twilio-ruby
  #   twilio_send_from_number = '+15551234567'
  #   twilio_client = Twilio::REST::Client.new twilio_id, twilio_token
  #   twilio_client.calls.create(
  #     from: twilio_send_from_number,
  #     to: user.phone_number,
  #     url: 'https://example.com/users/1/send_otp'
  #   )
  # end

  # You can use this block to hook into what happens when a one-time password token
  # needs to be sent via email. This allows you to customize the email contents.
  # config.on_send_otp_via_email = lambda do |user|
  #   MyMailer.send_otp(user).deliver_later
  # end

  # You can use this block to hook into what happens when user's phone number is
  # verified. Often, you'll want to send a thank you.
  # config.on_phone_verified = lambda do |user|
  #   # Example using Twilio - twilio-ruby
  #   twilio_send_from_number = '+15551234567'
  #   twilio_client = Twilio::REST::Client.new twilio_id, twilio_token
  #   twilio_client.messages.create(
  #     from: twilio_send_from_number,
  #     to: user.phone_number,
  #     body: 'Your phone has been verified!'
  #   )
  # end
end
