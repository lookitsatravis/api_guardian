# Api Guardian

Drop in authorization and authentication suite for Rails APIs.

## Overview

ApiGuardian includes the following features out of the box:

* User registration (email/pass)
* Password reset workflow
* Roles
* Permissions
* Stateless authentication using OAuth2 (via [Doorkeeper](https://github.com/doorkeeper-gem/doorkeeper) and [Doorkeeper::JWT](https://github.com/chriswarren/doorkeeper-jwt))
* Policy enforcement (via [Pundit](https://github.com/elabs/pundit))
* Serialization to [JSON API](http://jsonapi.org/) (via [AMS](https://github.com/rails-api/active_model_serializers))
* Two-factor auth (TODO)
* External Login (TODO)

What doesn't it include?

* Stateful session support (Cookies)
* HTML/CSS/JS or views of any kind.

## Requirements

* PostgreSQL >= 9.1 (uuid-ossp support)

**Note: For now, your app must use a PostgreSQL database.** This is because ApiGuardian is using UUID primary keys for all records.

## Installation

### First

Put this in your Gemfile:

```rb
gem 'api_guardian'
```

### Second

Run this command:

```sh
rake generate api_guardian:install
```

This will add an initializer, mount the routes, and, copy the migrations/seed files.
You will need to follow this with:

```sh
rake db:migrate
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

## Roadmap

* controller actions:
  * Assign permissions to role by name
  * validate user password
* config
  * password settings (44:1?)
    * devise_zxcvbn
  * user lockouts
  * 2fa settings
  * ???
* Generators
  * install (initializer, migrations, seed, routes)
  * ???
* omniauth
* Request logging
* Sessions/Devices (attach to tokens)
* Activity/Events (User signed in, User authenticated at...)
* Email Service/SMS Service
* Account lockout
* SSO
* digits integration
* Multi-tenancy
* Account lockout (failed login attempts)
* 2FA
  * http://blog.meldium.com/home/2013/8/23/screw-up-two-factor-authentication
  * https://www.authy.com/product/
  * https://github.com/heapsource/active_model_otp + Twilio
* Fix for JWT storage: https://github.com/doorkeeper-gem/doorkeeper/wiki/How-to-fix-PostgreSQL-error-on-index-row-size
* Cache

## Getting Help

If you find a bug, please report an [Issue](https://github.com/lookitsatravis/api_guardian/issues).

If you have a question, please post to [Stack Overflow](https://stackoverflow.com/questions/tagged/api_guardian).

Thanks!

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md)

## License

ApiGuardian is copyright © 2015 Travis Vignon. It is free software, and may be
redistributed under the terms specified in the [`MIT-LICENSE`](MIT-LICENSE) file.
