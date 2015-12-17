describe ApiGuardian do
  describe 'methods' do
    describe '.authenticate' do
      it 'can handle email authentication' do
        username = 'test'
        password = SecureRandom.hex(32)
        user = create(:user)
        expect(ApiGuardian::Helpers).to receive(:email_address?).with(username).and_return true
        expect(ApiGuardian::User).to receive(:find_by).with(email: username).and_return(user)
        expect(ApiGuardian::Strategies::Authentication::Password).to receive(:authenticate).with(user, password).and_return(user)

        result = ApiGuardian.authenticate(username, password)

        expect(result).to eq user
      end

      it 'can handle digits authentication' do
        username = 'test'
        password = SecureRandom.hex(32)
        user = create(:user)
        expect(ApiGuardian::Helpers).to receive(:email_address?).with(username).and_return false
        expect(ApiGuardian::Helpers).to receive(:phone_number?).with(username).and_return true
        expect(ApiGuardian::User).to receive(:find_by).with(phone_number: username).and_return(user)
        expect(ApiGuardian::Strategies::Authentication::Digits).to receive(:authenticate).with(user, password).and_return(user)

        result = ApiGuardian.authenticate(username, password)

        expect(result).to eq user
      end

      it 'returns nil otherwise' do
        username = 'test'
        expect(ApiGuardian::Helpers).to receive(:email_address?).with(username).and_return false
        expect(ApiGuardian::Helpers).to receive(:phone_number?).with(username).and_return false

        result = ApiGuardian.authenticate(username, '')

        expect(result).to eq nil
      end
    end
  end
end
