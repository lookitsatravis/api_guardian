describe ApiGuardian::Strategies::Authentication::Facebook do
  let(:base_klass) { ApiGuardian::Strategies::Authentication::Base }
  let(:klass) { ApiGuardian::Strategies::Authentication::Facebook }

  it 'registers facebook authentication strategy' do
    expect(base_klass.providers[:facebook]).to be_a klass
  end

  describe 'methods' do
    let(:user) { mock_model(ApiGuardian::User) }
    let(:identity) { mock_model(ApiGuardian::Identity) }
    let(:mock_response) { { 'email' => 'test', 'name' => 'test name', 'id' => '123' } }

    describe '#authenticate' do
      it 'fails if no user can be found via auth response' do
        expect_any_instance_of(ApiGuardian::Helpers::Facebook).to(
          receive(:authorize!).and_return(mock_response)
        )

        expect_any_instance_of(ApiGuardian::Stores::UserStore).to(
          receive(:find_by_email).and_return(nil)
        )

        result = subject.authenticate('')

        expect(result).to eq nil
      end

      it 'fails if no identity can be found for a user' do
        expect_any_instance_of(ApiGuardian::Helpers::Facebook).to(
          receive(:authorize!).and_return(mock_response)
        )

        expect_any_instance_of(ApiGuardian::Stores::UserStore).to(
          receive(:find_by_email).and_return(user)
        )

        expect(ApiGuardian::Stores::UserStore).to(
          receive(:find_identity_by_provider).with(user, :facebook).and_return(nil)
        )

        result = subject.authenticate('')

        expect(result).to eq nil
      end

      it 'fails if found identity does not match auth identity' do
        expect_any_instance_of(ApiGuardian::Helpers::Facebook).to(
          receive(:authorize!).and_return(mock_response)
        )

        expect_any_instance_of(ApiGuardian::Stores::UserStore).to(
          receive(:find_by_email).and_return(user)
        )

        expect(ApiGuardian::Stores::UserStore).to(
          receive(:find_identity_by_provider).with(user, :facebook).and_return(identity)
        )

        expect(identity).to receive(:provider_uid).and_return('cba')

        expect{subject.authenticate('')}.to(
          raise_error(ApiGuardian::Errors::IdentityAuthorizationFailed)
        )
      end

      it 'updates the user identity and returns user on success' do
        expect_any_instance_of(ApiGuardian::Helpers::Facebook).to(
          receive(:authorize!).and_return(mock_response)
        )

        expect_any_instance_of(ApiGuardian::Stores::UserStore).to(
          receive(:find_by_email).and_return(user)
        )

        expect(ApiGuardian::Stores::UserStore).to(
          receive(:find_identity_by_provider).with(user, :facebook).and_return(identity)
        )

        expect(identity).to receive(:provider_uid).and_return('123')

        expect(user).to receive(:active?).and_return true
        expect(identity).to receive(:update_attributes)

        result = subject.authenticate('')

        expect(result).to eq user
      end
    end
  end
end
