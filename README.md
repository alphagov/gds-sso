# GDS-SSO

This gem provides everything needed to integrate an application with [Signon](https://github.com/alphagov/signon). It's a wrapper around [OmniAuth](https://github.com/intridea/omniauth) that adds a 'strategy' for oAuth2 integration against Signon,
and the necessary controller to support that request flow.

Some of the applications that use this gem:

- [content-tagger](https://github.com/alphagov/content-tagger)
- [publishing-api](https://github.com/alphagov/publishing-api)
- [publisher](https://github.com/alphagov/publisher)
- [search-admin](https://github.com/alphagov/search-admin)

## Usage

### Integration with a Rails 4+ app

To use gds-sso you will need an oAuth client ID and secret for Signon or a compatible system.
These can be provided by one of the team with admin access to Signon.

Then include the gem in your Gemfile:

```ruby
gem 'gds-sso', '<version>'
```

Create a `config/initializers/gds-sso.rb` that looks like:

```ruby
GDS::SSO.config do |config|
  config.user_model   = 'User'

  # set up ID and Secret in a way which doesn't require it to be checked in to source control...
  config.oauth_id     = ENV['OAUTH_ID']
  config.oauth_secret = ENV['OAUTH_SECRET']

  # optional config for location of Signon
  config.oauth_root_url = "http://localhost:3001"

  # Pass in a caching adapter cache bearer token requests.
  config.cache = Rails.cache
end
```

The user model must include the `GDS::SSO::User` module.

It should have the following fields:

```ruby
string   "name"
string   "email"
string   "uid"
string   "organisation_slug"
string   "organisation_content_id"
array    "permissions"
boolean  "remotely_signed_out", :default => false
boolean  "disabled", :default => false
```

You also need to include `GDS::SSO::ControllerMethods` in your ApplicationController.

For ActiveRecord, you probably want to declare permissions as "serialized" like this:

```ruby
serialize :permissions, Array
```

### Securing your application

[GDS::SSO::ControllerMethods](/lib/gds-sso/controller_methods.rb) provides some useful methods for your application controllers.

To make sure that only people with a signon account and permission to use your app are allowed in use `authenticate_user!`.

```ruby
class ApplicationController < ActionController::Base
  include GDS::SSO::ControllerMethods
  before_action :authenticate_user!
  # ...
end
```

You can refine authorisation to specific controller actions based on permissions using `authorise_user!`. All permissions are assigned via Signon.

```ruby
class PublicationsController < ActionController::Base
  include GDS::SSO::ControllerMethods
  before_action :authorise_for_editing!, except: [:show, :index]
  # ...
private
  def authorise_for_editing!
    authorise_user!('edit_publications')
  end
end
```

`authorise_user!` can be configured to check for multiple permissions:

```ruby
# fails unless the user has at least one of these permissions
authorise_user!(any_of: %w(edit create))

# fails unless the user has both of these permissions
authorise_user!(all_of: %w(edit create))
```

The signon application makes sure that only users who have been granted access to the application can access it (e.g. they have the `signin` permission for your app).  This used to be left up to the applications themselves to check with the `require_signin_permission!` method.  This is now deprecated and can be removed from your controllers.  You should replace it with a call to `authenticate_user!` if you aren't already using that method, otherwise no signon authentication will be performed.

### Authorisation for API Users

In addition to the single-sign-on strategy, this gem also allows authorisation
via a "bearer token". This is used by publishing applications to be authorised
as an [API user](https://signon.publishing.service.gov.uk/api_users).

To authorise with a bearer token, a request has to be made with the header:

```
Authorization: Bearer your-token-here
```

This gem will then authenticate the token with the Signon application. If
valid, the API client will be authorised in the same way as a single-sign-on
user. The [gds-api-adapters gem](https://github.com/alphagov/gds-api-adapters#app-level-authentication)
has functionality for sending the bearer token for each request. To avoid making
these requests for each incoming request, specify a caching adapter like `Rails.cache`:

```ruby
GDS::SSO.config do |config|
  # ...
  # Pass in a caching adapter cache bearer token requests.
  config.cache = Rails.cache
end
```

If you are using a Rails 5 app in
[api_only](http://guides.rubyonrails.org/api_app.html) mode this gem will
automatically disable the oauth layers which use session persistence. You can
configure this gem to be in api_only mode (or not) with:

```ruby
GDS::SSO.config do |config|
  # ...
  # Only support bearer token authentication and send responses in JSON
  config.api_only = true
end
```

### Use in development mode

In development, you generally want to be able to run an application without needing to run your own SSO server to be running as well. GDS-SSO facilitates this by using a 'mock' mode in development. Mock mode loads an arbitrary user from the local application's user tables:

```ruby
GDS::SSO.test_user || GDS::SSO::Config.user_klass.first
```

To make it use a real strategy (e.g. if you're testing an app against the signon server), you will need to ensure that your Signon database has got OAuth config that matches what the apps use in development mode. To do this, run this in Signon:

```
bundle exec ./script/make_oauth_work_in_dev
```

Once that's done, set an environment variable when you run your app. e.g.:

```
GDS_SSO_STRATEGY=real bundle exec rails s
```

### Extra permissions for api users

By default the mock strategies will create a user with `signin` permission.

If your application needs different or extra permissions for access, you can specify this by adding the following to your config:

```ruby
GDS::SSO.config do |config|
  # other config here
  config.additional_mock_permissions_required = ["array", "of", "permissions"]
end
```

The mock bearer token will then ensure that the dummy api user has the required permission.

### Testing in your application

If your app is using `test-unit` or `minitest`, there is a linting test that can verify your `User` model is compatible with `GDS:SSO::User`:

```ruby
require 'gds-sso/lint/user_test'

class GDS::SSO::Lint::UserTest
  def user_class
    ::User
  end
end
```

Or if your app is using `rspec`, there is a [shared examples spec](/lib/gds-sso/lint/user_spec.rb):

```ruby
require 'gds-sso/lint/user_spec'

describe User do
  it_behaves_like "a gds-sso user class"
end
```

### Running the test suite

Run the tests with:

```
bundle exec rake
```

By default, the tests use the master of [Signon](https://github.com/alphagov/signon) for running integration tests. If you want to use a branch (or commit, or tag), you can run it like this:

```
SIGNON_COMMITISH=my_branch_name bundle exec rake
```

## Licence

[MIT License](LICENCE)
