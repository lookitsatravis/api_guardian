require 'faker'

describe ApiGuardian::Strategies::Authentication::Password do
  # Methods
  describe 'methods' do
    describe '.authencate' do
      it 'should authenticate a user by password' do
        password = Faker::Internet.password(32)

        user = create(:user, password: password, password_confirmation: password)

        result = ApiGuardian::Strategies::Authentication::Password.authenticate user, password

        expect(result).to eq user

        result = ApiGuardian::Strategies::Authentication::Password.authenticate user, 'password'

        expect(result).to eq nil
      end
    end
  end
end
