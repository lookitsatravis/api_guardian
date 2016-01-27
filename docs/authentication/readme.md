# ApiGuardian Authentication

Authentication with ApiGuardian is handled via OAuth2 spec. Upon successfully
authenticating, an access token is returned which sent in all future requests as
a header. *NOTE: Currently, ApiGuardian supports the `password` OAuth2 grant type. Future
additions of the other grant types are on the road map.*

Endpoint: POST `{engine_mount_path}/access/token`

## JWT Responses

ApiGuardian uses JSON Web Tokens as the generated access token. This is done as a
convenient way to provide clients with a given user's permission set (or claims).
More information on how to parse JWT and validate signatures can be found at
[jwt.io](https://jwt.io). *NOTE: Access Tokens are reused by ApiGuardian. This means
that if there are two or more successful authentications using the same resource owner
and app id, the access token granted will be reused as long as it is still valid.
The purpose of this behavior is to keep data storage low on large applications. It
also makes it easy to revoke tokens since there should only be a single valid one
at any given time.*

The successful authentication response looks like this:

```json
{
  "access_token": "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJhcGlfZ3VhcmRpYW4iLCJpYXQiOjE0NTIxODU3NzEsImV4cCI6MTQ1MjE5Mjk3MSwianRpIjoiMGNjMjNjY2ZiODQ5M2M3MDhmMDRhZGZiOTc1YzhhMTAiLCJzdWIiOiIzMzEyMWY5NS1mNzZkLTQ1NjUtOGYwNC00NjgyMjU4NDBlYWIiLCJ1c2VyIjp7ImlkIjoiMzMxMjFmOTUtZjc2ZC00NTY1LThmMDQtNDY4MjI1ODQwZWFiIn0sInBlcm1pc3Npb25zIjpbInJvbGU6bWFuYWdlIiwidXNlcjptYW5hZ2UiLCJwZXJtaXNzaW9uOm1hbmFnZSJdfQ.7cOk5loal4inq7b6qUV68cR5npheIQboqmCDvl0vy7o",
  "token_type": "bearer",
  "expires_in": 7200,
  "refresh_token": "59aa75573944f6df61ef9930ca0d8968210339c3d51bb13968604fe0b2123b1a",
  "created_at": 1452185771
}
```

In this case, the JWT payload decodes to the following. You can see that the user's
ID and permissions are included along with some of the standard JWT claims.

```json
{
  "iss": "api_guardian",
  "iat": 1452185771,
  "exp": 1452192971,
  "jti": "0cc23ccfb8493c708f04adfb975c8a10",
  "sub": "33121f95-f76d-4565-8f04-468225840eab",
  "user": {
    "id": "33121f95-f76d-4565-8f04-468225840eab"
  },
  "permissions": [
    "role:manage",
    "user:manage",
    "permission:manage"
  ]
}
```

The JWT issuer and secret can (and should) be customized. Please see configuration
for more.

## Email Authentication

To request an access token via email, the following fields are required.

```json
{
    "username": "person@example.com",
    "password": "somepassword",
    "grant_type": "password"
}
```

## [Twitter Digits](https://get.digits.com) Authentication

Digits also uses the `password` OAuth2 grant type. In this case, the username is
the phone number returned from the Digits SDK. In order to conform to the OAuth2
spec, a special step is needed to transform the Digits auth URL and Header into
a "password". To do this, you must Base64 encode the auth URL and the auth Header
joined by a semicolon. Example in JavaScript ([Digits web SDK docs](https://docs.fabric.io/web/digits/index.html)):

```js
Digits.init({ consumerKey: 'yourConsumerKey' });
Digits.logIn()
  .done(onLogin);

function onLogin(loginResponse){
  var oAuthHeaders = loginResponse.oauth_echo_headers;
  var apiUrl = oAuthHeaders['X-Auth-Service-Provider'];
  var authHeader = oAuthHeaders['X-Verify-Credentials-Authorization'];
  var encodedPassword = window.btoa([apiUrl, authHeader].join(';'))

  //encodedPassword is what you need to supply as the "password" to authenticate with Digits.
}
```

To request an access token via Twitter Digits, the following fields are required.

```js
{
    "username": "+18005551234", //As returned from Digits SDK
    "password": "base_64_encoded_url_and_header",
    "grant_type": "password"
}
```

## Two-Factor Authentication

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

### Enabling 2FA for a user

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

### Authenticating a user with 2FA

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

ApiGuardian is copyright © 2016 Travis Vignon. It is free software, and may be
redistributed under the terms specified in the [`MIT-LICENSE`](https://github.com/lookitsatravis/api_guardian/blob/master/MIT-LICENSE) file.
