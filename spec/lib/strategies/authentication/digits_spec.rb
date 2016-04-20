describe ApiGuardian::Strategies::Authentication::Digits do
  let(:base_klass) { ApiGuardian::Strategies::Authentication::Base }
  let(:klass) { ApiGuardian::Strategies::Authentication::Digits }

  it 'registers digits authentication strategy' do
    expect(base_klass.providers[:digits]).to be_a klass
  end

  describe 'methods' do
    let(:user) { mock_model(ApiGuardian::User) }
    let(:identity) { mock_model(ApiGuardian::Identity) }
    let(:body) { { 'phone_number' => 'test', 'id_str' => 'abc' } }
    let(:mock_response) { instance_double(Net::HTTPResponse) }

    describe '#authenticate' do
      it 'fails if auth response is invalid' do
        expect_any_instance_of(ApiGuardian::ValidationResult).to(
          receive(:succeeded).and_return(false)
        )

        result = subject.authenticate('')

        expect(result).to eq nil
      end

      it 'fails if no user can be found via auth response' do
        expect_any_instance_of(ApiGuardian::ValidationResult).to(
          receive(:succeeded).and_return(true)
        )
        expect_any_instance_of(ApiGuardian::Helpers::Digits).to(
          receive(:authorize!).and_return(mock_response)
        )

        expect(mock_response).to receive(:body).and_return('{}')
        expect(JSON).to receive(:parse).and_return(body)

        expect(ApiGuardian.configuration.user_class).to(
          receive(:find_by).and_return(nil)
        )

        result = subject.authenticate('')

        expect(result).to eq nil
      end

      it 'fails if no identity can be found for a user' do
        expect_any_instance_of(ApiGuardian::ValidationResult).to(
          receive(:succeeded).and_return(true)
        )
        expect_any_instance_of(ApiGuardian::Helpers::Digits).to(
          receive(:authorize!).and_return(mock_response)
        )

        expect(mock_response).to receive(:body).and_return('{}')
        expect(JSON).to receive(:parse).and_return(body)

        expect(ApiGuardian.configuration.user_class).to(
          receive(:find_by).and_return(user)
        )

        expect(ApiGuardian::Stores::UserStore).to(
          receive(:find_identity_by_provider).with(user, :digits).and_return(nil)
        )

        result = subject.authenticate('')

        expect(result).to eq nil
      end

      it 'fails if found identity does not match auth identity' do
        expect_any_instance_of(ApiGuardian::ValidationResult).to(
          receive(:succeeded).and_return(true)
        )
        expect_any_instance_of(ApiGuardian::Helpers::Digits).to(
          receive(:authorize!).and_return(mock_response)
        )

        expect(mock_response).to receive(:body).and_return('{}')
        expect(JSON).to receive(:parse).and_return(body)

        expect(ApiGuardian.configuration.user_class).to(
          receive(:find_by).and_return(user)
        )

        expect(ApiGuardian::Stores::UserStore).to(
          receive(:find_identity_by_provider).with(user, :digits).and_return(identity)
        )

        expect(identity).to receive(:provider_uid).and_return('cbba')

        expect{subject.authenticate('')}.to(
          raise_error(ApiGuardian::Errors::IdentityAuthorizationFailed)
        )
      end

      it 'updates the user identity and returns user on success' do
        expect_any_instance_of(ApiGuardian::ValidationResult).to(
          receive(:succeeded).and_return(true)
        )
        expect_any_instance_of(ApiGuardian::Helpers::Digits).to(
          receive(:authorize!).and_return(mock_response)
        )

        expect(mock_response).to receive(:body).and_return('{}')
        expect(JSON).to receive(:parse).and_return(body)

        expect(ApiGuardian.configuration.user_class).to(
          receive(:find_by).and_return(user)
        )

        expect(ApiGuardian::Stores::UserStore).to(
          receive(:find_identity_by_provider).with(user, :digits).and_return(identity)
        )

        expect(identity).to receive(:provider_uid).and_return('abc')

        expect(user).to receive(:active?).and_return true
        expect(identity).to receive(:update_attributes)

        result = subject.authenticate('')

        expect(result).to eq user
      end
    end
  end
end
