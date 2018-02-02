require 'spec_helper'
require 'gds-sso/bearer_token'

describe GDS::SSO::MockBearerToken do
  describe '.brute_force_permissions' do
    context 'with an empty permissions array' do
      it 'returns an array with both signin and internal_app' do
        permissions = []
        returned_permissions = GDS::SSO::MockBearerToken.brute_force_permissions(permissions: permissions)

        expect(returned_permissions).to contain_exactly('signin', 'internal_app')
      end
    end

    context 'with only one permissions' do
      it 'adds internal_app when signin is already present' do
        permissions = ['signin']
        returned_permissions = GDS::SSO::MockBearerToken.brute_force_permissions(permissions: permissions)

        expect(returned_permissions).to contain_exactly('signin', 'internal_app')
      end

      it 'adds signin when internal_app is already present' do
        permissions = ['internal_app']
        returned_permissions = GDS::SSO::MockBearerToken.brute_force_permissions(permissions: permissions)

        expect(returned_permissions).to contain_exactly('signin', 'internal_app')
      end

      it 'adds both signin and internal_app when neither is present' do

        permissions = ['some_other_permission']
        returned_permissions = GDS::SSO::MockBearerToken.brute_force_permissions(permissions: permissions)

        expect(returned_permissions).to contain_exactly('signin', 'internal_app', 'some_other_permission')
      end

    end
  end
end
