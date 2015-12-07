ApiGuardian.configure do |config|
  # In order to change the base user class, you'd need to uncomment this line and
  # enter your own class name. Your class will need to extend ApiGuardian::User.
  # config.user_class = 'User'

  # Change the minimum password length to set a user's password. Default is 8 add
  # it is recommended that it not be any lower.
  # config.minimum_password_length = 8

  # config.minimum_password_score = 4

  # Enable two-factor authentication
  # config.enable_2fa = true

  # 2FA header name. This header is used to validate a OTP and can be customized
  # to have the app name, for example.
  # config.otp_header_name = 'AG-2FA-TOKEN'

  # 2FA Send From Number. This is the Twilio number we will send from.
  # config.twilio_send_from = nil

  # Twilio Account SID and token (used with two-factor authentication)
  # config.twilio_id = nil
  # config.twilio_token = nil
end
