module GDS
  module SSO
    module Lint
      # Provides linting for classes including `GDS::SSO::User`
      #
      # In your project's `test/{unit,models}/user_test.rb`:
      #
      # require 'gds-sso/lint/user_test'
      #
      # class GDS::SSO::Lint::UserTest
      #   def user_class
      #     ::User
      #   end
      # end
      #
      # Where `::User` is your class including `GDS::SSO::User`
      #
      class UserTest < ActiveSupport::TestCase
        def user_class
          raise 'Reopen `GDS::SSO::Lint::UserTest` and add `#user_class` to return the class including `GDS::SSO::User`'
        end

        setup do
          @lint_user = user_class.new(uid: '12345')
        end

        should 'implement #where' do
          result = user_class.where(uid: '123')
          assert result.respond_to?(:first)
        end

        should 'implement #update_attribute' do
          @lint_user.update_attribute(:remotely_signed_out, true)
          assert @lint_user.remotely_signed_out?
        end

        should 'implement #update_attributes' do
          @lint_user.update_attributes(email: 'test@example.com')
          assert_equal @lint_user.email, 'test@example.com'
        end

        should 'implement #create!' do
          assert user_class.respond_to?(:create!)
        end

        should 'verify the User class and GDS::SSO::User work together' do
          auth_hash = {
            'uid' => '12345',
            'info' => {
              'name' => 'Joe Smith',
              'email' => 'joe.smith@example.com',
            },
            'extra' => {
              'user' => {
                'disabled' => false,
                'permissions' => ['signin'],
                'organisation_slug' => 'cabinet-office',
                'organisation_content_id' => '91e57ad9-29a3-4f94-9ab4-5e9ae6d13588',
              }
            }
          }

          user = user_class.find_for_gds_oauth(auth_hash)
          assert_equal user_class, user.class
          assert_equal '12345', user.uid
          assert_equal 'Joe Smith', user.name
          assert_equal 'joe.smith@example.com', user.email
          assert_equal false, user.disabled
          assert_equal ['signin'], user.permissions
          assert_equal 'cabinet-office', user.organisation_slug
          assert_equal '91e57ad9-29a3-4f94-9ab4-5e9ae6d13588', user.organisation_content_id
        end
      end
    end
  end
end
