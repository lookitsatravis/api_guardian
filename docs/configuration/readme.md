# ApiGuardian Configuration

ApiGuardian is intended to be configured with sensible defaults, but it is inevitable
that changes will need to be made from one application to another. Any changes
should be made in the initializer (`config/initializers/api_guardian.rb`) created
during installation. There are more options available than what is outlined here,
but these are the most common changes you're likely to make.

## Access Token Expiration

```rb
ApiGuardian.configure do |config|
  # ...

  # Access token expiration time (default 2 hours).
  config.access_token_expires_in = 2.weeks

  # ...
end
```

## Configuring JWT

You can customize the JWT issuer included in the payload as well as the secret
used for signing the token. *Note: You must chant the JWT secret. Requests will fail
if it is `nil` or the default value is used.*


```rb
ApiGuardian.configure do |config|
  # ...

  # JSON Web Tokens are used as the OAuth2 access token. Generating the JWT can
  # be configured in the following ways:
  #
  # The JWT issuer can be configured. The default is 'api_guardian_' with the
  # current version of ApiGuardian appended.
  config.jwt_issuer = 'my_app'
  #
  # The JWT secret can be customized to improve security of the JWT payload. By
  # default, a simple secret token is used. But, if you're using RS* encoding, you
  # must specify the path to your secret key.
  config.jwt_secret = 'changeme'
  config.jwt_secret_key_path = 'path/to/file.pem'
  #
  # The Encryption Method can use any of the valid methods found in
  # https://github.com/jwt/ruby-jwt. The default is HMAC 256.
  config.jwt_encryption_method = :hs256

  # ...
end
```

## Customizing Models/Tables

### Customizing Models

Most of the time, you will want to customize the models provided by ApiGuardian.
To customize a model, create a new model that includes the ApiGuardian concern.

The following models can be customized using the same method:

* User
* Identity
* Role*
* Permission*
* RolePermission*

\**Rarely needs to be customized.*

Example:

```rb
class User < ActiveRecord::Base
  include ApiGuardian::Concerns::Models::User

  def my_custom_method
    send_glitter_to_my_enemies
  end
end
```

And then in `config/initializers/api_guardian.rb`:

```rb
ApiGuardian.configure do |config|
  # ...

  config.user_class = 'User'
  # config.role_class = 'Role'
  # config.permission_class = 'Permission'
  # config.role_permission_class = 'RolePermission'
  # config.identity_class = 'Identity'

  # ...
end
```

You will need to restart the server after making this change.

### Customizing Tables

By default, this will use the database table created during install (`api_guardian_*`),
but you can change that by customizing the table name.

Example:

```rb
class User < ActiveRecord::Base
  include ApiGuardian::Concerns::Models::User
  self.table_name = 'users' # instead of api_guardian_users
end
```

Keep in mind that if you do this, the table will need to have the same schema as
`api_guardian_*`.

### Migrations

Along with the above info, you should remember that any new migrations need to
be added to the proper table. If you are using ApiGuardian and you *haven't*
customized the table name, then to add a column to the user model, you need to
add it to `api_guardian_users` and not simply `users`.

## minimum_password_length

## validate_password_score

## minimum_password_score

## mail_from_address

## Two Factor Authentication

See [Two-Factor Authentication](../authentication/readme.md#two-factor-authentication)

---

ApiGuardian is copyright © 2015-2020 Travis Vignon. It is free software, and may be
redistributed under the terms specified in the [`MIT-LICENSE`](https://github.com/lookitsatravis/api_guardian/blob/master/MIT-LICENSE) file.
