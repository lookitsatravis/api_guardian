describe ApiGuardian::Strategies::Authentication::Digits do
  let(:klass) { ApiGuardian::Strategies::Authentication::Digits }

  describe 'methods' do
    let(:user) { create(:user) }
    let(:identity) { create(:identity, user: user, provider: :digits) }

    describe '.authenticate' do
      it 'fails if user is nil' do
        result = klass.authenticate(nil, '')

        expect(result).to eq nil
      end

      it 'fails if digits identity does not exist' do
        expect(ApiGuardian::Stores::UserStore).to(
          receive(:find_identity_by_provider).and_return(nil)
        )

        result = klass.authenticate(user, '')

        expect(result).to eq nil
      end

      it 'returns nil if digits data does not validate' do
        validation_result = instance_double(ApiGuardian::ValidationResult)
        expect(ApiGuardian::Stores::UserStore).to(
          receive(:find_identity_by_provider).and_return(identity)
        )
        expect(Base64).to receive(:decode64).with('test').and_return('test')
        expect_any_instance_of(ApiGuardian::Helpers::Digits).to receive(:validate).and_return(validation_result)
        expect(validation_result).to receive(:succeeded).and_return false

        result = klass.authenticate(user, 'test')

        expect(result).to eq nil
      end

      it 'returns nil if digits authorize! fails' do
        validation_result = instance_double(ApiGuardian::ValidationResult)
        expect(ApiGuardian::Stores::UserStore).to(
          receive(:find_identity_by_provider).and_return(identity)
        )
        expect(Base64).to receive(:decode64).with('test').and_return('test')
        expect_any_instance_of(ApiGuardian::Helpers::Digits).to receive(:validate).and_return(validation_result)
        expect(validation_result).to receive(:succeeded).and_return true
        expect_any_instance_of(ApiGuardian::Helpers::Digits).to receive(:authorize!).and_raise(StandardError)

        result = klass.authenticate(user, 'test')

        expect(result).to eq nil
      end

      it 'authorizes digits data and return user' do
        validation_result = instance_double(ApiGuardian::ValidationResult)
        response = instance_double(Net::HTTPResponse)
        expect(ApiGuardian::Stores::UserStore).to(
          receive(:find_identity_by_provider).and_return(identity)
        )
        expect(Base64).to receive(:decode64).with('test').and_return('test')
        expect_any_instance_of(ApiGuardian::Helpers::Digits).to receive(:validate).and_return(validation_result)
        expect(validation_result).to receive(:succeeded).and_return true
        expect_any_instance_of(ApiGuardian::Helpers::Digits).to receive(:authorize!).and_return(response)
        expect(response).to receive(:body).and_return('{}')
        expect(identity).to receive(:update_attributes)

        result = klass.authenticate(user, 'test')

        expect(result).to eq user
      end
    end
  end
end
