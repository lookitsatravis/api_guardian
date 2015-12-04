ApiGuardian::Engine.routes.draw do
  # Registration
  post '/register' => 'registration#create'
  post '/reset-password' => 'registration#reset_password'
  post '/complete-reset-password' => 'registration#complete_reset_password'

  # API v1
  use_doorkeeper scope: 'auth' do
    skip_controllers :applications, :authorized_applications
  end

  resources :users, except: [:new, :edit] do
    get 'permissions', on: :member
  end

  resources :roles, except: [:new, :edit]
  resources :permissions, only: [:index]

  match '*unmatched_route', to: 'application#not_found', via: :all
end
