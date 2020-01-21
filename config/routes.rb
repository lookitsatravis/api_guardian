# frozen_string_literal: true

ApiGuardian::Engine.routes.draw do
  # Registration
  post '/register' => 'registration#create'
  post '/reset-password' => 'registration#reset_password'
  post '/complete-reset-password' => 'registration#complete_reset_password'

  # API v1
  use_doorkeeper scope: 'access' do
    skip_controllers :applications, :authorized_applications, :authorizations, :token_info
  end

  resources :users, except: [:new, :edit] do
    get 'permissions', on: :member
    post 'add_phone', on: :member
    post 'verify_phone', on: :member
    post 'change_password', on: :member
  end

  resources :roles, except: [:new, :edit]
  resources :permissions, only: [:index]

  match '*unmatched_route', to: 'application#not_found', via: :all
end

ApiGuardian::Engine.routes.default_url_options[:host] = Rails.application.routes.default_url_options[:host]
ApiGuardian::Engine.routes.default_url_options[:port] = Rails.application.routes.default_url_options[:port]
ApiGuardian::Engine.routes.default_url_options[:protocol] = Rails.application.routes.default_url_options[:protocol]
