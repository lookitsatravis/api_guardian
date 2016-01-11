require 'faker'

describe ApiGuardian::Strategies::Authentication::Base do
  let(:klass) { ApiGuardian::Strategies::Authentication::Base }

  # Methods
  describe 'methods' do
    describe '.autheticate' do
      it 'fails if the user is inactive' do
        user = create(:user, active: false)

        expect { klass.authenticate(user) }.to raise_error(ApiGuardian::Errors::UserInactive)
      end
    end
  end
end
