# frozen_string_literal: true

require 'faker'

describe ApiGuardian::Strategies::Authentication::Email do
  # Methods
  describe 'methods' do
    describe '#authencate' do
      it 'should authenticate a user by email/password' do
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
