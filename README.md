# Api Guardian

Drop in authorization and authentication suite for Rails APIs.

[![Build Status](	https://img.shields.io/travis/lookitsatravis/api_guardian.svg?style=flat-square)](https://travis-ci.org/lookitsatravis/api_guardian)
[![Test Coverage](https://img.shields.io/codeclimate/coverage/github/lookitsatravis/api_guardian.svg?style=flat-square)](https://codeclimate.com/github/lookitsatravis/api_guardian/coverage)
[![Code Climate](https://img.shields.io/codeclimate/github/lookitsatravis/api_guardian.svg?style=flat-square)](https://codeclimate.com/github/lookitsatravis/api_guardian)

## **\*\*This gem is in alpha stages and is not feature complete. It should not be used in production!\*\***

## Overview

ApiGuardian includes the following features out of the box:

* User registration (email/pass)
* Password reset workflow
* Roles
* Permissions
* Stateless authentication using OAuth2 (via [Doorkeeper](https://github.com/doorkeeper-gem/doorkeeper) and [Doorkeeper::JWT](https://github.com/chriswarren/doorkeeper-jwt))
* Policy enforcement (via [Pundit](https://github.com/elabs/pundit))
* Serialization to [JSON API](http://jsonapi.org/) (via [AMS](https://github.com/rails-api/active_model_serializers))
* Two-factor auth
* External Login (TODO)

What doesn't it include?

* Stateful session support (Cookies)
* HTML/CSS/JS or views of any kind.

## Requirements

* Ruby >= 2.0
* PostgreSQL >= 9.1 (uuid-ossp support)

**Note: For now, your app must use a PostgreSQL database.** This is because ApiGuardian is using UUID primary keys for all records.

## Installation

### First

Put this in your Gemfile:

```rb
# Include ApiGuardian from edge
gem 'api_guardian', git: 'https://github.com/lookitsatravis/api_guardian'
# You must also include the prerelease version of active_model_serializers
gem 'active_model_serializers', git: 'https://github.com/rails-api/active_model_serializers.git'
```

### Second

Run this command:

```sh
rails generate api_guardian:install
```

This will add an initializer, mount the routes, and copy the migrations files.
You will need to follow this with:

```sh
rake db:migrate
rake api_guardian:seed # not yet implemented, see db/seed.rb for example
```

### Third

To Do

### Finally

To Do

## Usage

### Roles

To Do

### Permissions

To Do

### Users

To Do

## Configuration

### Two-Factor Authentication

Two-Factor Authentication (2FA) functionality is available out of the box. Requirements:

* [Twilio](https://www.twilio.com/) account

To enable this feature, update the ApiGuardian config in `config/initializers/api_guardian.rb`:

```rb
ApiGuardian.configure do |config|
  # Enable two-factor authentication
  config.enable_2fa = true

  # 2FA header name. This header is used to validate a OTP and can be customized
  # to have the app name, for example.
  # config.otp_header_name = 'AG-2FA-TOKEN'

  # 2FA Send From Number. This is the Twilio number we will send from.
  config.twilio_send_from = 'YOUR_NUMBER' # formatted with country code, e.g. +18005551234

  # Twilio Account SID and token (used with two-factor authentication). These can be found
  # in your account.
  config.twilio_id = 'YOUR_TWILIO_SID'
  config.twilio_token = 'YOUR_TWILIO_AUTH_TOKEN'
end
```

*Note: Restart your server when done for the changes to take effect.*

#### Enabling 2FA for a user

To enable 2FA for a user, you will post their phone number, country code, and password to the API. You will need a valid access token. The user must supply their password in order to verify that it is the proper person to add a phone number to their record.

```sh
curl -X POST \
-H "Authorization: Bearer YOUR_ACCESS_TOKEN" \
-H "Content-Type: application/vnd.api+json" \
-H "Accept: application/vnd.api+json" \
-d \
'{
    "data": {
        "id": "USER_ID_HERE",
        "type": "users",
        "attributes": {
            "phone_number": "8005551234",
            "country_code": "1",
            "password": "password"
        }
    }
}' \
'http://localhost:3000/api/v1/users/USER_ID_HERE/add_phone'
```

The user will receive an SMS message with a six digit code. You will need to send it to the API in order to verify the phone number. This must be completed within 60 seconds of sending the code.

```sh
curl -X POST \
-H "Authorization: Bearer YOUR_ACCESS_TOKEN" \
-H "Content-Type: application/vnd.api+json" \
-H "Accept: application/vnd.api+json" \
-d \
'{
    "data": {
        "id": "USER_ID_HERE",
        "type": "users",
        "attributes": {
            "otp": "SIX_DIGIT_SMS_CODE",
        }
    }
}' \
'http://localhost:3000/api/v1/users/USER_ID_HERE/verify_phone'
```

The user will receive a confirmation SMS and the verification is now complete.

#### Authenticating a user with 2FA

Authenticating with 2FA enabled is mostly the same as standard authentication using a password grant. Make the authentication request like normal:

```sh
curl -X POST \
-H "Content-Type: application/json" \
-d \
'{
    "email": "travis@lookitsatravis.com",
    "password": "password",
    "grant_type": "password"
}' \
'http://localhost:3000/api/v1/auth/token'
```

If the user has 2FA enabled, you will get a 402 response with a code of `two_factor_required`. The server will send the OTP to the user via SMS, and the client should present the user with a form to submit the code. When this happens, you will resubmit the access token request with an additional header (`AG-2FA-TOKEN` is the default value, though this is configurable) where the value is the OTP.

```sh
curl -X POST \
-H "Content-Type: application/json" \
-H "AG-2FA-TOKEN: SIX_DIGIT_SMS_CODE" \
-d \
'{
    "email": "travis@lookitsatravis.com",
    "password": "password",
    "grant_type": "password"
}' \
'http://localhost:3000/api/v1/auth/token'
```

If done properly, you should be rewarded with an access token. If the OTP is incorrect or has expired, you will simply get a 401 http status invalid_grant response and you must start again.

## Roadmap

* controller actions:
  * Assign permissions to role by name
  * validate user password
* digits integration
* Multi-tenancy
  * Invite users by email to organization
  * Users can belong to multiple organizations
  * Different roles based on organization? Or permissions?
* Add pepper/salt to bcrypt
  * https://github.com/plataformatec/devise/blob/master/lib/devise/encryptor.rb
  * http://api.rubyonrails.org/classes/ActiveModel/SecurePassword/InstanceMethodsOnActivation.html
  * https://github.com/thoughtbot/clearance/blob/master/lib/clearance/password_strategies/bcrypt.rb
* omniauth
* Account lockout (failed login attempts)
* https://github.com/kickstarter/rack-attack
* 2FA
  * review support for https://www.authy.com/product/
  * review support for U2F
  * 2FA via voice call
  * Generate URL for Google Authenticator import
  * Backup codes for when device is unavailable
    * 16 one time use codes
    * Ability to regenerate a new batch of codes
* Activity/Events (User signed in, User authenticated at...)
* Sessions/Devices (attach to tokens)
* Fix for JWT storage: https://github.com/doorkeeper-gem/doorkeeper/wiki/How-to-fix-PostgreSQL-error-on-index-row-size
* Cache
* SSO
* Documentation
  * Microservice usage
  * Request logging

## Getting Help

If you find a bug, please report an [Issue](https://github.com/lookitsatravis/api_guardian/issues).

If you have a question, please post to [Stack Overflow](https://stackoverflow.com/questions/tagged/api_guardian).

Thanks!

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md)

## License

ApiGuardian is copyright © 2015 Travis Vignon. It is free software, and may be
redistributed under the terms specified in the [`MIT-LICENSE`](MIT-LICENSE) file.
