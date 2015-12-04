describe 'ApiGuardian::UsersController' do
  # Authentication and permissions are tested elsewhere
  before(:each) { @routes = ApiGuardian::Engine.routes }
  before(:each) { seed_permissions('user') }
  before(:each) { auth_user }
  after(:each) { destroy_user }

  describe 'RESOURCE /users' do
    describe 'GET /' do
      it 'returns a list of users' do
        add_user_permission('user:read')

        get '/users', {}, get_headers

        expect(response).to have_http_status(:ok)
      end
    end

    describe 'POST /' do
      it 'creates a new user' do
        add_user_permission('user:create')
        user = create(:user)

        allow_any_instance_of(ApiGuardian::Stores::UserStore).to receive(:create).and_return(user)

        data = { data: { type: 'users', attributes: { name: '', default: false, permissions: [] } } }

        post '/users', data.to_json, get_headers

        expect(response).to have_http_status(:created)
      end
    end

    describe 'GET /{:permission_id}' do
      it 'gets a user by id' do
        add_user_permission('user:read')
        user = create(:user)

        allow_any_instance_of(ApiGuardian::Stores::UserStore).to receive(:find).and_return(user)

        get "/users/#{user.id}", {}, get_headers

        expect(response).to have_http_status(:ok)
      end
    end

    describe 'PATCH /{:permission_id}' do
      it 'updates a user by id' do
        add_user_permission('user:update')
        user = create(:user)

        allow_any_instance_of(ApiGuardian::Stores::UserStore).to receive(:update).and_return(user)

        data = { data: { type: 'users', id: "#{user.id}", attributes: { name: Faker::Lorem.word, default: false } } }

        patch "/users/#{user.id}", data.to_json, get_headers

        expect(response).to have_http_status(:ok)
      end
    end

    describe 'DELETE /{:permission_id}' do
      it 'deletes a user by id' do
        add_user_permission('user:delete')
        user = create(:user)

        allow_any_instance_of(ApiGuardian::Stores::UserStore).to receive(:destroy).and_return(user)

        delete "/users/#{user.id}", {}, get_headers

        expect(response).to have_http_status(:no_content)
      end
    end
  end
end
