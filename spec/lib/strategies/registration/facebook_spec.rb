describe ApiGuardian::Strategies::Registration::Facebook do
  let(:base_klass) { ApiGuardian::Strategies::Registration::Base }
  let(:klass) { ApiGuardian::Strategies::Registration::Facebook }

  it 'registers facebook registration strategy' do
    expect(base_klass.providers[:facebook]).to be_a klass
  end

  it 'sets allowed API parameters' do
    [:access_token].each do |f|
      expect(klass.params).to include(f)
    end
  end

  describe 'methods' do
    let(:mock_facebook) { instance_double(ApiGuardian::Helpers::Facebook) }
    let(:mock_response) { { 'id' => '54321', 'name' => 'Travis Vignon', 'email' => 'test@example.com' } }

    describe '#register' do
      it 'should authorize digits request and create user' do
        attributes = {}
        user = mock_model(ApiGuardian::User)
        role = mock_model(ApiGuardian::Role)
        expect_any_instance_of(ApiGuardian::Helpers::Facebook).to receive(:authorize!).and_return(mock_response)
        store = double(ApiGuardian::Stores::UserStore)
        expect(ApiGuardian::Stores::UserStore).to receive(:new).and_return(store)
        expect(ApiGuardian::Stores::RoleStore).to receive(:default_role).and_return(role)
        expect(store).to receive(:create_with_identity).and_return(user)

        result = subject.register(ApiGuardian::Stores::UserStore, attributes)

        expect(result).to eq user
      end
    end

    describe 'data hash creation' do
      describe '#build_user_attributes_from_response' do
        it 'should build user data hash' do
          role = mock_model(ApiGuardian::Role)
          expect(ApiGuardian::Stores::RoleStore).to receive(:default_role).and_return(role)

          result = subject.build_user_attributes_from_response(
            mock_response,
            password: 'password',
            password_confirmation: 'password'
          )

          expect(result).to be_a Hash
          expect(result[:first_name]).to eq 'Travis'
          expect(result[:last_name]).to eq 'Vignon'
          expect(result[:email]).to eq 'test@example.com'
          expect(result[:email_confirmed_at]).to be_a Time
          expect(result[:role_id]).to eq role.id
          expect(result[:active]).to eq true
          expect(result[:password]).to eq 'password'
          expect(result[:password_confirmation]).to eq 'password'
        end

        it 'should generate strong password if one is not provided' do
          role = mock_model(ApiGuardian::Role)
          expect(ApiGuardian::Stores::RoleStore).to receive(:default_role).and_return(role)

          result = subject.build_user_attributes_from_response(mock_response)

          expect(result[:password]).to be_a String
          expect(result[:password].length).to eq 64
          expect(result[:password_confirmation]).to be_a String
          expect(result[:password_confirmation].length).to eq 64
          expect(result[:password_confirmation]).to eq result[:password]
        end
      end

      describe '#build_identity_attributes_from_response' do
        it 'should build identity data hash' do
          result = subject.build_identity_attributes_from_response(mock_response, '12345')

          expect(result).to be_a Hash
          expect(result[:provider]).to eq 'facebook'
          expect(result[:provider_uid]).to eq '54321'
          expect(result[:tokens]).to eq(access_token: '12345')
        end
      end
    end
  end
end
