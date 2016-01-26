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
* PostgreSQL >= 9.3 (JSON and uuid-ossp support)

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

### Next

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

### Finally

See our [Documentation](docs/readme.md) for way more information on setup and usage.

## Roadmap

* controller actions:
  * Assign permissions to role by name
* Multi-tenancy
  * Invite users by email to organization
  * Users can belong to multiple organizations?
  * Different roles based on organization? Or permissions?
* Configuring allowed CORS domains (to better protect insecure clients)
* omniauth
* Account lockout (failed login attempts)
* https://github.com/kickstarter/rack-attack
* 2FA
  * review support for https://www.authy.com/product/
  * review support for U2F
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
* Remove dependency on PostgreSQL
  * Use serialize for attributes in models
  * https://github.com/jashmenn/activeuuid

## Getting Help

If you find a bug, please report an [Issue](https://github.com/lookitsatravis/api_guardian/issues).

If you have a question, please post to [Stack Overflow](https://stackoverflow.com/questions/tagged/api_guardian).

Thanks!

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md)

## License

ApiGuardian is copyright © 2016 Travis Vignon. It is free software, and may be
redistributed under the terms specified in the [`MIT-LICENSE`](MIT-LICENSE) file.
