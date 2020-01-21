# frozen_string_literal: true

describe 'ApiGuardian::RolesController' do
  # Authentication and permissions are tested elsewhere
  before(:each) { @routes = ApiGuardian::Engine.routes }
  before(:each) { seed_permissions('role') }
  before(:each) { auth_user }
  after(:each) { destroy_user }

  describe 'RESOURCE /roles' do
    describe 'GET /' do
      it 'returns a list of roles' do
        add_user_permission('role:read')

        get '/roles', params: {}, headers: get_headers

        expect(response).to have_http_status(:ok)
      end
    end

    describe 'POST /' do
      it 'creates a new role' do
        add_user_permission('role:create')
        role = create(:role)

        allow_any_instance_of(ApiGuardian::Stores::RoleStore).to receive(:create).and_return(role)

        data = { data: { type: 'roles', attributes: { name: '', default: false, permissions: [] } } }

        post '/roles', params: data.to_json, headers: get_headers

        expect(response).to have_http_status(:created)
      end
    end

    describe 'GET /{:role_id}' do
      it 'gets a role by id' do
        add_user_permission('role:read')
        role = create(:role)

        allow_any_instance_of(ApiGuardian::Stores::RoleStore).to receive(:find).and_return(role)

        get "/roles/#{role.id}", params: {}, headers: get_headers

        expect(response).to have_http_status(:ok)
      end
    end

    describe 'PATCH /{:role_id}' do
      it 'updates a role by id' do
        add_user_permission('role:update')
        role = create(:role)

        allow_any_instance_of(ApiGuardian::Stores::RoleStore).to receive(:update).and_return(role)

        data = { data: { type: 'roles', id: role.id.to_s, attributes: { name: Faker::Lorem.word, default: false } } }

        patch "/roles/#{role.id}", params: data.to_json, headers: get_headers

        expect(response).to have_http_status(:ok)
      end
    end

    describe 'DELETE /{:role_id}' do
      it 'deletes a role by id' do
        add_user_permission('role:delete')
        role = create(:role)

        allow_any_instance_of(ApiGuardian::Stores::RoleStore).to receive(:destroy).and_return(role)

        delete "/roles/#{role.id}", params: {}, headers: get_headers

        expect(response).to have_http_status(:no_content)
      end
    end
  end
end
