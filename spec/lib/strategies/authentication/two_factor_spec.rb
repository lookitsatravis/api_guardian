# frozen_string_literal: true

require 'faker'

describe ApiGuardian::Strategies::Authentication::TwoFactor do
  # Methods
  describe 'methods' do
    let(:user) { mock_model(ApiGuardian::User) }
    let(:mock_request) { instance_double(ActionDispatch::Request) }

    describe '.authenticate_request' do
      it 'returns true if 2FA is disabled' do
        expect(ApiGuardian.configuration).to receive(:enable_2fa).and_return(false)

        result = ApiGuardian::Strategies::Authentication::TwoFactor.authenticate_request(user, mock_request)

        expect(result).to be true
      end

      it 'returns true if user\'s does not have OTP enabled' do
        expect(ApiGuardian.configuration).to receive(:enable_2fa).and_return(true)
        expect(user).to receive(:otp_enabled).and_return false

        result = ApiGuardian::Strategies::Authentication::TwoFactor.authenticate_request(user, mock_request)

        expect(result).to be true
      end

      it 'queues SendOtp and fails if OTP header value is missing' do
        mock_headers = instance_double(ActionDispatch::Http::Headers)
        expect(ApiGuardian.configuration).to receive(:enable_2fa).and_return(true)
        expect(user).to receive(:otp_enabled).and_return true
        expect(ApiGuardian.configuration).to receive(:otp_header_name).and_return('X-TEST')
        expect(mock_request).to receive(:headers).and_return(mock_headers)
        expect(mock_headers).to receive(:[]).with('X-TEST').and_return('')

        expect(ApiGuardian::Jobs::SendOtp).to receive(:perform_later).with(user)

        expect do
          ApiGuardian::Strategies::Authentication::TwoFactor.authenticate_request(user, mock_request)
        end.to raise_error ApiGuardian::Errors::TwoFactorRequired
      end

      it 'returns the value of authenticate_otp if code present' do
        mock_headers = instance_double(ActionDispatch::Http::Headers)
        expect(ApiGuardian.configuration).to receive(:enable_2fa).and_return(true)
        expect(user).to receive(:otp_enabled).and_return true
        expect(ApiGuardian.configuration).to receive(:otp_header_name).and_return('X-TEST')
        expect(mock_request).to receive(:headers).and_return(mock_headers)
        expect(mock_headers).to receive(:[]).with('X-TEST').and_return('000')
        expect(user).to receive(:authenticate_otp).with('000', drift: 30).and_return true

        result = ApiGuardian::Strategies::Authentication::TwoFactor.authenticate_request(user, mock_request)

        expect(result).to be true
      end

      it 'returns false supplied otp is invalid' do
        mock_headers = instance_double(ActionDispatch::Http::Headers)
        expect(ApiGuardian.configuration).to receive(:enable_2fa).and_return(true)
        expect(user).to receive(:otp_enabled).and_return true
        expect(ApiGuardian.configuration).to receive(:otp_header_name).and_return('X-TEST')
        expect(mock_request).to receive(:headers).and_return(mock_headers)
        expect(mock_headers).to receive(:[]).with('X-TEST').and_return('000')
        expect(user).to receive(:authenticate_otp).with('000', drift: 30).and_return false

        result = ApiGuardian::Strategies::Authentication::TwoFactor.authenticate_request(user, mock_request)

        expect(result).to be false
      end

      it 'should authenticate otp header value' do
        password = Faker::Internet.password(min_length: 32)

        user = create(:user, password: password, password_confirmation: password)

        result = ApiGuardian::Strategies::Authentication::Email.new.authenticate email: user.email, password: password

        expect(result).to eq user

        result = ApiGuardian::Strategies::Authentication::Email.new.authenticate email: user.email, password: 'password'

        expect(result).to eq nil
      end
    end
  end
end
