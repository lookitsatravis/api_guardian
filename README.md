# Api Guardian

Drop in authorization and authentication suite for Rails APIs.

[![Build Status](	https://img.shields.io/travis/lookitsatravis/api_guardian.svg?style=flat-square)](https://travis-ci.org/lookitsatravis/api_guardian)
[![Test Coverage](https://img.shields.io/codeclimate/coverage/lookitsatravis/api_guardian.svg?style=flat-square)](https://codeclimate.com/github/lookitsatravis/api_guardian/coverage)
[![Code Climate](https://img.shields.io/codeclimate/maintainability/lookitsatravis/api_guardian.svg?style=flat-square)](https://codeclimate.com/github/lookitsatravis/api_guardian)

Special thanks to [Anton Visser](https://github.com/toneplex) for his work and support on this project.

## Overview

ApiGuardian includes the following features out of the box:

* User registration (email/pass)
* Stateless authentication using OAuth2 (via [Doorkeeper](https://github.com/doorkeeper-gem/doorkeeper) and [Doorkeeper::JWT](https://github.com/chriswarren/doorkeeper-jwt))
* Roles and Permissions
* Password reset workflow
* Guest access
* Policy enforcement (via [Pundit](https://github.com/elabs/pundit))
* Serialization to [JSON API](http://jsonapi.org/) (via [fast_jsonapi](https://github.com/Netflix/fast_jsonapi))
* Two-factor support
* Extensable to support any auth or registration strategies

What doesn't it include?

* Stateful session support (Cookies)
* HTML/CSS/JS or views of any kind.

## Requirements

* Ruby >= 2.5
* PostgreSQL >= 9.3 (JSON and uuid-ossp support)
* Rails >= 6.0

**Note: For now, your app must use a PostgreSQL database.** This is because ApiGuardian is using UUID primary keys for all records.

## Quick Start

### First

Put this in your Gemfile:

```rb
# Include ApiGuardian from edge
gem 'api_guardian', git: 'https://github.com/lookitsatravis/api_guardian'
```

### Next

Run the following command. It will:

* Add an initializer
* Mount ApiGuardian in your routes file
* Copy migration files
* Add seed data

```sh
rails generate api_guardian:install
```

You will need to follow this with:

```sh
rake db:migrate
```

Take a moment here to review your seed file and make any changes. And then:

```sh
rake db:seed
```

### Finally

Make all of your API controllers extend `ApiGuardian::ApiController` and your
policies extend `ApiGuardian::Policies::ApplicationPolicy`. What is a policy, you ask,
and why should you care? Well, [I'm glad you asked](docs/authorization/readme.md)!

See our [Documentation](docs/readme.md) for way more information on setup and usage,
or take a look at the RDoc formatted docs here:

http://www.rubydoc.info/github/lookitsatravis/api_guardian/master

## Roadmap

* controller actions:
  * Assign permissions to role by name
* Multi-tenancy
  * Invite users by email to organization
  * Users can belong to multiple organizations?
  * Different roles based on organization? Or permissions?
* Configuring allowed CORS domains (to better protect insecure clients)
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
* Sessions/Devices (attach to tokens, but how?)
* Fix for JWT storage: https://github.com/doorkeeper-gem/doorkeeper/wiki/How-to-fix-PostgreSQL-error-on-index-row-size
* Cache
* SSO
* Documentation
  * Microservice usage
  * Request logging
* Remove dependency on PostgreSQL
  * Use serialize for attributes in models
  * https://github.com/jashmenn/activeuuid
* Ability to swap AMS adapter
  * Error rendering needs to match this setting
* Toggle custom logger off
* Add test for custom logger
* A role can't be destroyed if users still belong to it

## Getting Help

If you find a bug, please report an [Issue](https://github.com/lookitsatravis/api_guardian/issues).

If you have a question, please post to [Stack Overflow](https://stackoverflow.com/questions/tagged/api_guardian).

Thanks!

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md)

## License

ApiGuardian is copyright © 2015-2020 Travis Vignon. It is free software, and may be
redistributed under the terms specified in the [`MIT-LICENSE`](MIT-LICENSE) file.
