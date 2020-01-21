# frozen_string_literal: true

require 'faker'

describe 'Default routes', type: :routing do
  routes { ApiGuardian::Engine.routes }

  context 'for user registration' do
    it 'POST /register routes to registration#create' do
      expect(post('/register')).to route_to('api_guardian/registration#create')
    end

    it 'POST /reset-password routes to registration#reset_password' do
      expect(post('/reset-password')).to route_to('api_guardian/registration#reset_password')
    end

    it 'POST /complete-reset-password routes to registration#complete_reset_password' do
      expect(post('/complete-reset-password')).to route_to('api_guardian/registration#complete_reset_password')
    end
  end

  context 'for Doorkeeper' do
    # it 'GET /auth/authorize/:code routes to doorkeeper/authorizations#show' do
    #   expect(get('/auth/authorize/code')).to route_to(
    #     controller: 'api_guardian/doorkeeper/authorizations',
    #     action: 'show',
    #     code: 'code'
    #   )
    # end
    #
    # it 'GET /auth/authorize routes to doorkeeper/authorizations#new' do
    #   expect(get('/auth/authorize')).to route_to('api_guardian/doorkeeper/authorizations#new')
    # end
    #
    # it 'POST /auth/authorize routes to doorkeeper/authorizations#create' do
    #   expect(post('/auth/authorize')).to route_to('api_guardian/doorkeeper/authorizations#create')
    # end
    #
    # it 'DELETE /auth/authorize routes to doorkeeper/authorizations#destroy' do
    #   expect(delete('/auth/authorize')).to route_to('api_guardian/doorkeeper/authorizations#destroy')
    # end

    it 'POST /auth/token routes to doorkeeper/tokens#create' do
      expect(post('/access/token')).to route_to('api_guardian/doorkeeper/tokens#create')
    end

    it 'POST /auth/revoke routes to doorkeeper/tokens#revoke' do
      expect(post('/access/revoke')).to route_to('api_guardian/doorkeeper/tokens#revoke')
    end

    # it 'GET /auth/token/info routes to doorkeeper/token_info#show' do
    #   expect(get('/auth/token/info')).to route_to('api_guardian/doorkeeper/token_info#show')
    # end
  end

  context 'for Users' do
    it 'GET /users/1/permissions routes to users#permissions' do
      expect(get('/users/1/permissions')).to route_to(
        controller: 'api_guardian/users',
        action: 'permissions',
        id: '1'
      )
    end

    it 'POST /users/1/add_phone routes to users#add_phone' do
      expect(post('/users/1/add_phone')).to route_to(
        controller: 'api_guardian/users',
        action: 'add_phone',
        id: '1'
      )
    end

    it 'POST /users/1/verify_phone routes to users#verify_phone' do
      expect(post('/users/1/verify_phone')).to route_to(
        controller: 'api_guardian/users',
        action: 'verify_phone',
        id: '1'
      )
    end

    it 'POST /users/1/change_password routes to users#change_password' do
      expect(post('/users/1/change_password')).to route_to(
        controller: 'api_guardian/users',
        action: 'change_password',
        id: '1'
      )
    end

    it 'GET /users routes to users#index' do
      expect(get('/users')).to route_to('api_guardian/users#index')
    end

    it 'POST /users routes to users#create' do
      expect(post('/users')).to route_to('api_guardian/users#create')
    end

    it 'GET /users/1 routes to users#show' do
      expect(get('/users/1')).to route_to(
        controller: 'api_guardian/users',
        action: 'show',
        id: '1'
      )
    end

    it 'PATCH /users/1 routes to users#update' do
      expect(patch('/users/1')).to route_to(
        controller: 'api_guardian/users',
        action: 'update',
        id: '1'
      )
    end

    it 'PUT /users/1 routes to users#update' do
      expect(put('/users/1')).to route_to(
        controller: 'api_guardian/users',
        action: 'update',
        id: '1'
      )
    end

    it 'DELETE /users/1 routes to users#destroy' do
      expect(delete('/users/1')).to route_to(
        controller: 'api_guardian/users',
        action: 'destroy',
        id: '1'
      )
    end
  end

  context 'for Roles' do
    it 'GET /roles routes to roles#index' do
      expect(get('/roles')).to route_to('api_guardian/roles#index')
    end

    it 'POST /roles routes to roles#create' do
      expect(post('/roles')).to route_to('api_guardian/roles#create')
    end

    it 'GET /roles/1 routes to roles#show' do
      expect(get('/roles/1')).to route_to(
        controller: 'api_guardian/roles',
        action: 'show',
        id: '1'
      )
    end

    it 'PATCH /roles/1 routes to roles#update' do
      expect(patch('/roles/1')).to route_to(
        controller: 'api_guardian/roles',
        action: 'update',
        id: '1'
      )
    end

    it 'PUT /roles/1 routes to roles#update' do
      expect(put('/roles/1')).to route_to(
        controller: 'api_guardian/roles',
        action: 'update',
        id: '1'
      )
    end

    it 'DELETE /roles/1 routes to roles#destroy' do
      expect(delete('/roles/1')).to route_to(
        controller: 'api_guardian/roles',
        action: 'destroy',
        id: '1'
      )
    end
  end

  context 'for Permissions' do
    it 'GET /permissions routes to permissions#index' do
      expect(get('/permissions')).to route_to('api_guardian/permissions#index')
    end
  end

  context 'for all other routes' do
    it 'GET,POST,PUT,PATCH,DELETE,OPTIONS,HEAD /asdfasdf routes to application#not_found' do
      %w(GET POST PUT PATCH DELETE OPTIONS HEAD).each do |method|
        random_route = []

        rand(1..4).times do
          random_route << Faker::Internet.slug(words: Faker::Lorem.words(number: 4).join(' '), glue: '-')
        end

        expect(send(method.downcase, random_route.join('/'))).to route_to(
          controller: 'api_guardian/application',
          action: 'not_found',
          unmatched_route: random_route.join('/')
        )
      end
    end
  end
end
