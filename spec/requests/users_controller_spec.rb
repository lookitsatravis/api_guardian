# frozen_string_literal: true

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

        get '/users', params: {}, headers: get_headers

        expect(response).to have_http_status(:ok)
      end
    end

    describe 'POST /' do
      it 'creates a new user' do
        add_user_permission('user:create')
        user = create(:user)

        allow_any_instance_of(ApiGuardian::Stores::UserStore).to receive(:create).and_return(user)

        data = { data: { type: 'users', attributes: { name: '', default: false, permissions: [] } } }

        post '/users', params: data.to_json, headers: get_headers

        expect(response).to have_http_status(:created)
      end
    end

    describe 'GET /{:user_id}' do
      it 'gets a user by id' do
        add_user_permission('user:read')
        user = create(:user)

        allow_any_instance_of(ApiGuardian::Stores::UserStore).to receive(:find).and_return(user)

        get "/users/#{user.id}", params: {}, headers: get_headers

        expect(response).to have_http_status(:ok)
      end
    end

    describe 'PATCH /{:user_id}' do
      it 'updates a user by id' do
        add_user_permission('user:update')
        user = create(:user)

        allow_any_instance_of(ApiGuardian::Stores::UserStore).to receive(:update).and_return(user)

        data = { data: { type: 'users', id: user.id.to_s, attributes: { name: Faker::Lorem.word, default: false } } }

        patch "/users/#{user.id}", params: data.to_json, headers: get_headers

        expect(response).to have_http_status(:ok)
      end
    end

    describe 'DELETE /{:user_id}' do
      it 'deletes a user by id' do
        add_user_permission('user:delete')
        user = create(:user)

        allow_any_instance_of(ApiGuardian::Stores::UserStore).to receive(:destroy).and_return(user)

        delete "/users/#{user.id}", params: {}, headers: get_headers

        expect(response).to have_http_status(:no_content)
      end
    end

    describe 'POST /{:user_id}/add_phone' do
      it 'adds phone to user' do
        add_user_permission('user:update')
        user = create(:user)

        allow_any_instance_of(ApiGuardian::Stores::UserStore).to receive(:add_phone).and_return(user)

        data = {
          data: {
            type: 'users',
            id: user.id.to_s,
            attributes: { phone_number: Faker::PhoneNumber.phone_number }
          }
        }

        post "/users/#{user.id}/add_phone", params: data.to_json, headers: get_headers

        expect(response).to have_http_status(:no_content)
      end
    end

    describe 'POST /{:user_id}/verify_phone' do
      it 'returns error if phone verification fails' do
        add_user_permission('user:update')
        user = create(:user)

        allow_any_instance_of(ApiGuardian::Stores::UserStore).to receive(:verify_phone).and_return(false)

        data = { data: { type: 'users', id: user.id.to_s, attributes: { otp: '000' } } }

        post "/users/#{user.id}/verify_phone", params: data.to_json, headers: get_headers

        expect(response).to have_http_status(:unprocessable_entity)
      end

      it 'verifies user\'s phone' do
        add_user_permission('user:update')
        user = create(:user)

        allow_any_instance_of(ApiGuardian::Stores::UserStore).to receive(:verify_phone).and_return(true)

        data = { data: { type: 'users', id: user.id.to_s, attributes: { otp: '000' } } }

        post "/users/#{user.id}/verify_phone", params: data.to_json, headers: get_headers

        expect(response).to have_http_status(:ok)
      end
    end

    describe 'POST /{:user_id}/change_password' do
      it 'changes a user\'s password' do
        add_user_permission('user:update')
        user = create(:user)

        allow_any_instance_of(ApiGuardian::Stores::UserStore).to receive(:change_password).and_return(user)

        new_pass = SecureRandom.hex(64)

        data = { data: { type: 'users', id: user.id.to_s, attributes: {
          password: new_pass, new_password: new_pass, new_password_confirmation: new_pass
        } } }

        post "/users/#{user.id}/change_password", params: data.to_json, headers: get_headers

        expect(response).to have_http_status(:ok)
      end
    end
  end
end
