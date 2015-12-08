# 11.2.1

* Use `test` for maximum compatibility of test-unit/minitest `User` linter

# 11.2.0

* Add a test-unit/minitest compatible linter for validating that the `User`
  model is compatible with GDS SSO
* Add `disabled` attribute expectation to the existing RSpec shared example

# 11.1.0

* Pin dependencies to prevent updating to non-compatible versions

# 11.0.0

* Rerelease of 10.1.0

# 10.1.0 (includes a breaking change)

* Breaking change: Add support for organisation_content_id on the user model

# 10.0.1

* Fix the user model linter to work with a uid column defined as `NOT NULL`
* Strengthen lint specs around user `update_attributes` method

# 10.0.0

* Add a `disabled` field to GDS::SSO::User to reflect Signon user state.
  Breaking change: Requires consuming apps to add a `disabled` field to their user model

# 9.4.0

* Add an RSpec shared example for validating that the User model in the app
  does enough to work with GDS SSO. To use it:

  ```ruby
  require 'gds-sso/lint/user_spec'

  describe User do
    it_behaves_like "a gds-sso user class"
  end
  ```

# 9.3.0

* Include oauth client_id when requesting user details from signon.
  This allows signon to verify that the token used belongs to the app making
  the request.  Sending this id will become mandatory in future.

# 9.2.7

* update/reauth requests get a content-type of 'text/plain' in responses

# 9.2.6

* Adds support for string timestamps in serialized sessions (Rails 4.1).
* New sessions are created using ISO 8601 string timestamps.

# 9.2.5

* Change find_for_gds_oauth to find by UID then fall-back to email
  This fixes an issue when users logging into preview are duplicated
  as UIDs are not synced.

# 9.2.4

* Fix bug in creation of dummy API user in test mode

# 9.2.3

* Minor bugfix to allow building of gems such as govuk_content_models which do
  not load rails.

# 9.2.2

* Includes fix to get the mock_gds_sso_api_access
  strategy working in development for apps that
  don't have a role attribute on User.

# 9.2.1

* Using User#where instead of User#find_by_email
  in mock gds api user warden strategy, to make
  it compatible with apps using mongoid.

# 9.2.0

* UX fix to check whether remotely signed out user
  signed-in again to let them continue. otherwise,
  ask them to login again.

# 8.0.0

* The controllers provided by gds-sso no longer inherit from an application's
  ApplicationController, and instead inherit directly from
  ActionController::Base.

# 7.0.0

* Changed "organisation" to "organisation_slug"

# 6.0.0 (Not recommended, see version 7.0.0)

* Changed "organisations" (array) to "organisation" (string)

# 5.0.0 (Not recommended, see version 7.0.0)

* Apps using gds-sso must now include a field in their User model for
  "organisations", which is an array of organisation slugs sourced from
  https://whitehall-admin.production.alphagov.co.uk/api/organisations

# 4.0.0

* Removed support for basic authentication. Please use Bearer token
  authentication instead. This means creating API users and granting them
  appropriate permissions. See the Signonotron README for more information:
  https://github.com/alphagov/signonotron2#usage
