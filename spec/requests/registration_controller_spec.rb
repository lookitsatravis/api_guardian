# frozen_string_literal: true

describe 'Registration' do
  before(:each) do
    create(:default_role)
  end

  let(:headers) { { 'Accept' => 'application/json', 'Content-Type' => 'application/json' } }

  describe 'POST /register' do
    it 'fails if provider is not a string' do
      expect_any_instance_of(ActionController::Parameters).to receive(:require).with(:type)
      expect_any_instance_of(ActionController::Parameters).to receive(:fetch).with(:type, nil).and_return([])

      post '/register', params: {}, headers: headers

      expect(response).to have_http_status(400)
    end

    it 'registers a user' do
      mock_strategy = double(ApiGuardian::Strategies::Registration::Email)
      expect_any_instance_of(ActionController::Parameters).to receive(:require).with(:type)
      expect_any_instance_of(ActionController::Parameters).to receive(:fetch).with(:type, nil).and_return('test')
      expect(ApiGuardian::Strategies::Registration).to receive(:find_strategy).with('test').and_return(mock_strategy)
      expect(mock_strategy).to receive(:params).and_return([])
      expect_any_instance_of(ActionController::Parameters).to receive(:permit).with(:type, *[])
      expect(ApiGuardian::Stores::UserStore).to receive(:register).and_return(true)

      post '/register', params: {}, headers: headers

      expect(response).to have_http_status(:created)
      # TODO: Validate JSON output
    end

    # it 'fails on invalid email' do
    #   data = {password: 'password', password_confirmation: 'password' }
    #
    #   post '/register', data.to_json, headers
    #
    #   validate_unprocessable_entity(
    #     [{field: 'email', detail: 'can\'t be blank' }]
    #   )
    # end
    #
    # it 'fails on duplicate email' do
    #   email = Faker::Internet.email
    #   create(:user, email: email)
    #   data = { email: email, password: 'password', password_confirmation: 'password' }
    #
    #   post '/register', data.to_json, headers
    #
    #   validate_unprocessable_entity(
    #     [{field: 'email', detail: 'has already been taken' }]
    #   )
    # end
    #
    # it 'fails on password mismatch' do
    #   data = { email: Faker::Internet.email, password: 'password', password_confirmation: 'password1' }
    #
    #   post '/register', data.to_json, headers
    #
    #   validate_unprocessable_entity(
    #     [{field: 'password_confirmation', detail: 'doesn\'t match Password' }]
    #   )
    # end
    #
    # it 'fails on password length error' do
    #   data = { email: Faker::Internet.email, password: 'pass', password_confirmation: 'pass' }
    #
    #   post '/register', data.to_json, headers
    #
    #   validate_unprocessable_entity(
    #     [{field: 'password', detail: 'is too short (minimum is 8 characters)' }]
    #   )
    # end
  end

  describe 'POST /reset-password' do
    it 'resets a users password' do
      # TODO: don't skip params
      allow_any_instance_of(ActionController::Parameters).to receive(:fetch).and_return({})
      expect(ApiGuardian::Stores::UserStore).to receive(:reset_password).and_return(true)

      post '/reset-password', params: {}, headers: headers

      expect(response).to have_http_status(:no_content)
    end

    it 'renders not found when user is missing' do
      # TODO: don't skip params
      allow_any_instance_of(ActionController::Parameters).to receive(:fetch).and_return({})
      expect(ApiGuardian::Stores::UserStore).to receive(:reset_password).and_return(false)

      post '/reset-password', params: {}, headers: headers

      validate_not_found '/reset-password'
    end
  end

  describe 'POST /complete-reset-password' do
    it 'completes the password reset process' do
      expect(ApiGuardian::Stores::UserStore).to receive(:complete_reset_password).and_return(true)

      post '/complete-reset-password', params: {}, headers: headers

      expect(response).to have_http_status(:no_content)
    end

    it 'renders not found when user is missing' do
      expect(ApiGuardian::Stores::UserStore).to receive(:complete_reset_password).and_return(false)

      post '/complete-reset-password', params: {}, headers: headers

      validate_not_found '/complete-reset-password'
    end

    # it 'fails when token mismatches user' do
    #   user = create(:user, email: Faker::Internet.email)
    #   user.reset_password_token = SecureRandom.hex(64)
    #   user.reset_password_sent_at = DateTime.now.utc
    #   user.save

    #   data = {
    #     email: Faker::Internet.email,
    #     token: user.reset_password_token,
    #     password: 'password',
    #     password_confirmatin: 'password'
    #   }

    #   post '/complete-reset-password', data.to_json, headers

    #   validate_api_error(
    #     status: 403,
    #     code: 'reset_token_mismatch',
    #     title: 'Reset Token Mismatch',
    #     detail: 'Reset token is not valid for the supplied email address.'
    #   )
    # end

    # it 'fails when token is expired' do
    #   user = create(:user, email: Faker::Internet.email)
    #   user.reset_password_token = SecureRandom.hex(64)
    #   user.reset_password_sent_at = 36.hours.ago.utc
    #   user.save

    #   data = {
    #     email: user.email,
    #     token: user.reset_password_token,
    #     password: 'password',
    #     password_confirmatin: 'password'
    #   }

    #   post '/complete-reset-password', data.to_json, headers

    #   validate_api_error(
    #     status: 403,
    #     code: 'reset_token_expired',
    #     title: 'Reset Token Expired',
    #     detail: 'This reset token has expired. Tokens are valid for 24 hours.'
    #   )
    # end
    #
    # it 'fails when the password is blank' do
    #   user = create(:user, email: Faker::Internet.email)
    #   user.reset_password_token = SecureRandom.hex(64)
    #   user.reset_password_sent_at = DateTime.now.utc
    #   user.save
    #
    #   data = { email: user.email, token: user.reset_password_token}
    #
    #   post '/complete-reset-password', data.to_json, headers
    #
    #   validate_unprocessable_entity(
    #     [{field: 'password', detail: 'can\'t be blank'}]
    #   )
    # end
  end
end
