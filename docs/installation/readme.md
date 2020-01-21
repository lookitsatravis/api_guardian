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

## Controllers & Such

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

### Policies

Policies are used to tell ApiGuardian who is allowed to access what resource and where.
You'll have to create a policy for each resource. ApiGuardian's built-in policy
will handle many simple CRUD actions for you based on permissions, but there will
be many times when you'll want fine-grained control over records. Read more about
Policies [here](../authorization/readme.md#policies).

### Stores

In order for ApiGuardian to handle CRUD actions for your controllers, you must add
a store for your model. The store should be named with the name of your model, and
'Store' (e.g. a model named "Foo" will have a "FooStore".). Your stores must extend
`ApiGuardian::Stores::Base`. The Base store class includes methods for finding,
creating, updating, and deleting resources. Of course, you can override and/or add
to a store to implement custom functionality, but ApiGuardian will handle basic CRUD
for you out of the box.

The idea of a Store is to abstract the actual implementation of the data storage
model from ApiGuardian. Currently, ApiGuardian supports ActiveRecord, but the
plan is to provide other adapters in the future. There are several ways to accomplish
this, but ApiGuardian is using this simple repository to help hide
behind-the-scenes implementation from controllers and reduce code duplication. Here
is an example implementation.

Say you have a model ("Widget"). You will create a `WidgetStore` which looks like this:

```rb
class WidgetStore < ApiGuardian::Stores::Base
end
```

You would create `widget_store.rb` file in `app/stores` directory.

Now, when you hit your `WidgetsController`, ApiGuardian will use `WidgetStore` to
interact with your models instead of interacting with them directly. This flexibility
will allow you to extend the Store or the Model (or both) with extra functionality
and will keep it out of your controllers. Perhaps when you create a Widget, you need
to email a user, or post to a Slack channel. You can do this in the store in the "create"
method, and keep all of that code our of your controller. In the future, you'll
even be able to swap out your model implementation (to Mongoid, for example), and
hopefully leave the majority of your code (especially controllers) alone.

#### But I Don't Want To Use A Store

Well, you don't have to! You can instead create your own base controller and only
use the features of ApiGuardian you want (like error handling). But, you won't
get any of the awesome automatic CRUD authorization that ApiGuardian is designed
to make simple.

Even if this idea is new to you or you're skeptical of it, you might try out the store
pattern and see how it works for you. I think you'll find that it's a great way
to write Rails apps, or any app for that matter. Keeping the binding between data
and the client simple (your controllers) is a great benefit. It reduces technical
debt, code duplication, and helps organize your business logic.

## Serializers

ApiGuardian is using [fast_jsonapi](https://github.com/Netflix/fast_jsonapi)
as the method of returning data to the client. 

In order for ApiGuardian to serialize your data, you must add
a serializer. The serializer should be named with the name of your model, and
'Serializer' (e.g. a model named "Foo" will have a "FooSerializer".). Your serializers must extend
`ApiGuardian::Serializers::Base`.

You can take the serializer further and define an index serializer and a show serializer. This allows you
to have only the necessary information in the index response and more information in the show response.
The show, update and create methods will use the show serializer if present.
eg. "FooIndexSerializer" or "FooShowSerializer".

---

ApiGuardian is copyright © 2015-2020 Travis Vignon. It is free software, and may be
redistributed under the terms specified in the [`MIT-LICENSE`](https://github.com/lookitsatravis/api_guardian/blob/master/MIT-LICENSE) file.
