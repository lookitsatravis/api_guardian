describe ApiGuardian::Strategies::Registration::Digits do
  let(:base_klass) { ApiGuardian::Strategies::Registration::Base }
  let(:klass) { ApiGuardian::Strategies::Registration::Digits }

  it 'registers digits registration strategy' do
    expect(base_klass.providers[:digits]).to be_a klass
  end

  it 'adds digits_key config option' do
    expect(ApiGuardian.configuration.registration).to respond_to(:digits_key=)
    expect(ApiGuardian.configuration.registration).to respond_to(:digits_key)
  end

  it 'sets allowed API parameters' do
    [:auth_url, :auth_header].each do |f|
      expect(klass.params).to include(f)
    end
  end

  describe 'methods' do
    let(:mock_digits) { instance_double(ApiGuardian::Helpers::Digits) }

    describe '#validate' do
      it 'should validate using digits helper' do
        expect_any_instance_of(ApiGuardian::Helpers::Digits).to receive(:validate)

        subject.validate({})
      end
    end

    describe '#register' do
      it 'should authorize digits request and create user' do
        attributes = {}
        user = mock_model(ApiGuardian::User)
        role = mock_model(ApiGuardian::Role)
        mock_response = instance_double(Net::HTTPResponse)
        expect_any_instance_of(ApiGuardian::Helpers::Digits).to(
          receive(:validate).and_return(ApiGuardian::ValidationResult.new(true))
        )
        expect_any_instance_of(ApiGuardian::Helpers::Digits).to receive(:authorize!).and_return(mock_response)
        expect(mock_response).to receive(:body).twice.and_return('{}')
        store = double(ApiGuardian::Stores::UserStore)
        expect(ApiGuardian::Stores::UserStore).to receive(:new).and_return(store)
        expect(ApiGuardian::Stores::RoleStore).to receive(:default_role).and_return(role)
        expect(store).to receive(:create_with_identity).and_return(user)

        result = subject.register(ApiGuardian::Stores::UserStore, attributes)

        expect(result).to eq user
      end
    end

    describe 'data hash creation' do
      let(:access_token) do
        {
          'token' => '1234',
          'secret' => '0987'
        }
      end

      let(:attributes) do
        {
          'phone_number' => '18005551234',
          'id_str' => '12345',
          'access_token' => access_token
        }
      end

      describe '#build_user_attributes_from_response' do
        it 'should build user data hash' do
          role = mock_model(ApiGuardian::Role)
          expect(ApiGuardian::Stores::RoleStore).to receive(:default_role).and_return(role)

          result = subject.build_user_attributes_from_response(
            attributes,
            password: 'password',
            password_confirmation: 'password'
          )

          expect(result).to be_a Hash
          expect(result[:phone_number]).to eq '18005551234'
          expect(result[:phone_number_confirmed_at]).to be_a Time
          expect(result[:role_id]).to eq role.id
          expect(result[:active]).to eq true
          expect(result[:password]).to eq 'password'
          expect(result[:password_confirmation]).to eq 'password'
        end

        it 'should generate strong password if one is not provided' do
          role = mock_model(ApiGuardian::Role)
          expect(ApiGuardian::Stores::RoleStore).to receive(:default_role).and_return(role)

          result = subject.build_user_attributes_from_response(attributes)

          expect(result[:password]).to be_a String
          expect(result[:password].length).to eq 64
          expect(result[:password_confirmation]).to be_a String
          expect(result[:password_confirmation].length).to eq 64
          expect(result[:password_confirmation]).to eq result[:password]
        end
      end

      describe '#build_identity_attributes_from_response' do
        it 'should build identity data hash' do
          result = subject.build_identity_attributes_from_response(attributes)

          expect(result).to be_a Hash
          expect(result[:provider]).to eq 'digits'
          expect(result[:provider_uid]).to eq '12345'
          expect(result[:tokens]).to eq access_token
        end
      end
    end
  end
end
