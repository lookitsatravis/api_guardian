# ApiGuardian Authorization

## Roles & Permissions

ApiGuardian gives you a flexible role & permission suite out of the box. During
installation, it adds the seed data for the roles and permissions required by ApiGuardian
itself. But, obviously you'll want to customize this. Here's what you might need
to know.

### Adding a Role
A Role simply needs a name.

```rb
hugger = ApiGuardian.configuration.role_class.create!(name: 'Professional Hugger')
```

You can also specify the default role by passing `default: true` attribute.

### Giving it Permissions

A Role has no permissions by default. Not false permissions, just no permissions.
You can do a couple of things to set permissions for a role. First, you can add
them individually by name:

```rb
ApiGuardian.configuration.permission_class.create!(
  name: 'bear_hug', desc: 'Has the ability to give bear hugs. Duh.'
)
hugger.add_permission('bear_hug')
```

or remove one if you'd like

```rb
ApiGuardian.configuration.permission_class.create!(
  name: 'smooch', desc: 'A pro hugger wouldn\'t ever smooch, right?'
)
hugger.remove_permission('smooch') # permission is no longer granted
```

*Note: An error is thrown if you try to add/remove a permission that doesn't exist.*

You can also blanked add permissions to a Role. This will grant (or not) all permissions
currently in the database.

```rb
hugger.create_default_permissions true # or false if you want to lock this role down
```

### Assigning Users

Assigning a user to a role is simple.

```rb
user = ApiGuardian.configuration.user_class.find("8f199149-e2a7-41a3-8540-b69c2125aa74")
user.role = hugger
user.save
```

### Checking Permissions

Once you've created a role and assigned it to some users, you will likely want
to check that user's permissions from time to time. This is as simple as:

```rb
user.can? 'bear_hug' # true
user.can? 'smooch' # false
```

You can also pass an array of permissions. `can?` will return true if any of them
are valid.

```rb
user.can? ['bear_hug', 'smooch'] # true
```

*Note: These examples are so dumb. But I'm super tired.*

### Resource CRUD Permissions

CRUD permissions are treated just slightly differently. They are still created the
same way, but there are some special cases. First, you should format a resources's
permissions like this:

```rb
perm = ApiGuardian.configuration.permission_class
perm.create!(name: 'widget:create', desc: 'Ability to create Widget resource.')
perm.create!(name: 'widget:read', desc: 'Ability to read Widget resource.')
perm.create!(name: 'widget:update', desc: 'Ability to update Widget resource.')
perm.create!(name: 'widget:delete', desc: 'Ability to delete Widget resource.')
perm.create!(name: 'widget:manage', desc: 'Ability to manage Widget resource.')
```

Notice the format `#{resource_name}:#{action}`. `resource_name` is the lowercase,
singular spelling of the resource. `action` is one of `create`, `read`, `update`, `delete`,
or `manage`. **The format is important because the built-in policies (we'll get to those)
will handle CRUD authorization automatically for a user so long as:**

1. You set up your permissions correctly
1. Your controllers extend `ApiGuardian::ApiController`
1. Your policies subclass ApiGuardian's application policy

Finally, the `manage` action is a special case even still because if `manage` is
granted for a role, then that user can take action on a resource even if the
action is disallowed by another permission. Example:

```rb
user.role.add_permission('widget:manage')
user.role.remove_permission('widget:create')

# When a user access the Widgets controller "create" action, they will still be
# allowed to create the record even though they do not have the `create` action.
```

## Users

We've covered a lot about users above, and specific things like configuration,
registration, and authentication are handled in [other parts of the docs](../readme.md).

This section will be added to over time as necessary.

## Policies

ApiGuardian implements [Pundit](https://github.com/elabs/pundit) as a means of
handling policies for API actions. Besides verifying a user has access at all and
has proved that they belong on your server (authentication), policies handle the
next big chunk of functionality - authorization. Pundit policies are designed to
run on every single controller action. If it's not run, then it's either a public
API endpoint, or you're being very lazy. Here's the gist of it.

ApiGuardian includes policies for users, roles, and permissions. In general, you
shouldn't have to tweak them - or at least that's the idea. But if you do, it's best
that you extend the respective policy (`ApiGuardian::Policies::#{x}Policy`).
*Note: A user can manage themselves always, and other users can only manage them if they
have the proper permissions.*

### Using ApiController and ApplicationPolicy

In your application, you need to do two things. First, your controllers need to
extend `ApiGuardian::ApiController`. This will (among other things) load up and
enforce Pundit policies. Second, your policies (at the very least, you should
have one for each model) should extend `ApiGuardian::Policies::ApplicationPolicy`.

#### ApiController

`ApiGuardian::ApiController` is awesome because not only does it handle authentication
for you, but also authorization. For CRUD, setting up a custom controller is darn
simple:

```rb
class WidgetsController < ApiGuardian::ApiController
  def includes
    []
  end

  def create_params
    []
  end

  def update_params
    []
  end
end
```

Whoa. I thought there'd be more code. But seriously, there isn't. You get full CRUD
authentication and authorization without writing any more code in your controller.
Those three methods which return arrays...here's what they do:

* `#includes` takes an array of strings which represent related models. Active Model
Serializers will then include that related data in the JSON output. Example:

```rb
class CarsController < ApiGuardian::ApiController
  def includes
    ['manufacturer']
  end
end
```

The return JSON would include the car or cars records, and the related manufacturer.
This is simply sugar to save a bit of boilerplate.

* `#create_params` and `#update_params` isn't anything new if you're familiar with
strong parameters concepts and examples. It's an array of symbols representing the
allowed attributes for a model.

##### Request Validation and Customizing Content Types

The JSON API spec says that clients have to use `application/vnd.api+json` content types. So, all requests are validated to to be sure that they meet this format. However, you may also find that you need to deviate from the JSON API spec a bit when doing things like uploading files. JSON API doesn't have anything to say about files, so in this case, we have the ability to add allowed content types for a given action on a controller. Simply do the following:

```rb
class CarsController < ApiGuardian::ApiController
  allow_content_type 'multipart/form-data', actions: [:create]

  # ...

  def create
    # Now the create action will still pass validation with a different content type.
  end

  # ...
end
```

#### ApplicationPolicy

`ApiGuardian::Policies::ApplicationPolicy` has special Magic® which allows it to automatically map controller
actions to the current users permissions. So, when a user creates a Widget via
the controllers `create` action, the Widget policy will automatically check to
see if that user has `widget:create` or `widget:manage` permissions. For simple CRUD,
it's so damn simple.

### Everything Else

Please see the awesome [Pundit](https://github.com/elabs/pundit) repo for more
on custom policies. ApiGuardian doesn't differ from their examples at all except
that it uses `user.can?` to determine authorization inside the policies.

ApiGuardian is copyright © 2015-2020 Travis Vignon. It is free software, and may be
redistributed under the terms specified in the [`MIT-LICENSE`](https://github.com/lookitsatravis/api_guardian/blob/master/MIT-LICENSE) file.
