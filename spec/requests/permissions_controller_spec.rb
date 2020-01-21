# frozen_string_literal: true

describe 'ApiGuardian::PermissionsController' do
  # Authentication and permissions are tested elsewhere
  before(:each) { @routes = ApiGuardian::Engine.routes }
  before(:each) { seed_permissions('permission') }
  before(:each) { auth_user }
  after(:each) { destroy_user }

  describe 'RESOURCE /permissions' do
    describe 'GET /' do
      it 'returns a list of permissions' do
        add_user_permission('permission:read')

        get '/permissions', params: {}, headers: get_headers

        expect(response).to have_http_status(:ok)
      end
    end
  end
end
