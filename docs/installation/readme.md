# ApiGuardian Installation

## First

Put this in your Gemfile:

```rb
# Include ApiGuardian from edge
gem 'api_guardian', git: 'https://github.com/lookitsatravis/api_guardian'
# You must also include the prerelease version of active_model_serializers
gem 'active_model_serializers', git: 'https://github.com/rails-api/active_model_serializers.git'
```

## Next

Run the following command. It will:

* Add an initializer
  * skip with `--skip-initializer` argument
* Mount ApiGuardian in your routes file
  * skip with `--skip-routes` argument
* Copy migration files
  * skip with `--skip-migrations` argument
* Add seed data
  * skip with `--skip-seed` argument

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

## Routing

ApiGuardian by default is mounted to '/auth'. So all ApiGuardian endpoints are prefixed
by '/auth'. Like:

* `/auth/register`
* `/auth/access/token`
* `/auth/users`

You can easily change this in your route file.

## Models

You may find that you need to customize some of the included models (ex: `ApiGuardian::User`).
We give you the flexibility out of the box to use custom classes that still behave
the way ApiGuardian expects. See [Customizing Models/Tables](../configuration/readme.md#customizing-modelstables)
for more information.

## Controllers

See much more information [here](../authorization/readme.md#policies).

### `ApiGuardian::ApiController`

In order to have your controllers take advantage of ApiGuardian, they must extend
`ApiGuardian::ApiController`. The ApiController is responsible for verifying the
access token, validating the request body, error handling, verifying scopes, and
a handful of other tasks.

### `ApiGuardian::ApplicationController`

We also provide a controller that you can extend but have more flexibility with.
It will still handle errors in the same way that ApiController does, but it does
not do request validation, or access token checking. This is a great class for API
endpoints that are public or are otherwise more relaxed.


ApiGuardian is copyright © 2016 Travis Vignon. It is free software, and may be
redistributed under the terms specified in the [`MIT-LICENSE`](https://github.com/lookitsatravis/api_guardian/blob/master/MIT-LICENSE) file.
