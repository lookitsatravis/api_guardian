describe ApiGuardian::Stores::UserStore do
  # Methods
  describe 'methods' do
    describe '#find_by_email' do
      it 'should find user by email' do
        expect(ApiGuardian::User).to receive(:find_by_email).with('test')

        subject.find_by_email('test')
      end
    end

    describe '#find_by_reset_password_token' do
      it 'should find user by reset password token' do
        expect(ApiGuardian::User).to receive(:find_by_reset_password_token).with('test')

        subject.find_by_reset_password_token('test')
      end
    end

    describe '#create' do
      it 'should set default attributes before saving' do
        attributes = {}
        role = mock_model(ApiGuardian::Role)
        expect(role).to receive(:id).and_return(1)
        expect(ApiGuardian::Stores::RoleStore).to receive(:default_role).and_return(role)
        expect_any_instance_of(ApiGuardian::User).to receive(:valid?).and_return(true)
        expect_any_instance_of(ApiGuardian::User).to receive(:save!).and_return(true)

        subject.create(attributes)

        expect(attributes[:role_id]).to eq 1
        expect(attributes[:email_confirmed_at]).to be_a(DateTime)
        expect(attributes[:active]).to eq true
      end
    end

    describe '#add_phone' do
      it 'fails on invalid phone number' do
        user = mock_model(ApiGuardian::User)
        expect(subject).to receive(:check_password).and_return(true)
        expect(Phony).to receive(:normalize).once
        expect(Phony).to receive(:plausible?).once.and_return(false)

        expect{subject.add_phone(user, {})}.to raise_error ApiGuardian::Errors::PhoneNumberInvalid
      end

      it 'adds number and queues SendOtp job' do
        example_number = '8009876543'
        user = mock_model(ApiGuardian::User)
        expect(subject).to receive(:check_password).and_return(true)
        expect(Phony).to receive(:normalize).once.and_return("1#{example_number}")
        expect(Phony).to receive(:plausible?).once.and_return(true)
        expect(user).to receive(:phone_number=).with "1#{example_number}"
        expect(user).to receive(:phone_number_confirmed_at=).with nil
        expect(user).to receive(:save!)
        expect(ApiGuardian::Jobs::SendOtp).to receive(:perform_later).with(user)

        subject.add_phone(user, {phone_number: example_number})
      end
    end

    describe '#verify_phone' do
      it 'returns false if otp auth fails' do
        user = mock_model(ApiGuardian::User)
        expect(user).to receive(:authenticate_otp).and_return false

        result = subject.verify_phone(user, {})

        expect(result).to be false
      end

      it 'confirms phone and queues SendSms job with success message' do
        user = mock_model(ApiGuardian::User)
        expect(user).to receive(:authenticate_otp).and_return true
        expect(user).to receive(:phone_number_confirmed_at=)
        expect(user).to receive(:save)
        expect(ApiGuardian::Jobs::SendSms).to receive(:perform_later).with(
          user, 'Your phone has been verified!'
        )

        result = subject.verify_phone(user, {})

        expect(result).to be true
      end
    end

    describe '.register' do
      it 'fails on invalid attributes' do
        role = mock_model(ApiGuardian::Role)
        expect(role).to receive(:id).and_return(1)
        expect(ApiGuardian::Stores::RoleStore).to receive(:default_role).and_return(role)
        allow_any_instance_of(ApiGuardian::User).to receive(:valid?).and_return(false)

        expect { ApiGuardian::Stores::UserStore.register({}) }.to raise_error ActiveRecord::RecordInvalid
      end

      it 'creates inactive user with unconfirmed email and default role' do
        role = mock_model(ApiGuardian::Role)
        user = create(:user)
        expect(role).to receive(:id).and_return(1)
        expect(ApiGuardian::Stores::RoleStore).to receive(:default_role).and_return(role)
        expect(ApiGuardian::User).to receive(:new).and_return(user)
        expect_any_instance_of(ApiGuardian::User).to receive(:valid?).and_return(true)
        expect_any_instance_of(ApiGuardian::User).to receive(:save!).and_return(true)

        result = ApiGuardian::Stores::UserStore.register({})

        expect(result.role_id).to eq user.role_id
        expect(result.active).to be false
        expect(result.email_confirmed_at).to be nil
      end
    end

    describe '.reset_password' do
      it 'resets on valid email' do
        user = mock_model(ApiGuardian::User)
        expect(user).to receive(:reset_password_token=)
        expect(user).to receive(:reset_password_sent_at=)
        expect(user).to receive(:save)

        allow_any_instance_of(ApiGuardian::Stores::UserStore).to receive(:find_by_email).and_return(user)

        result = ApiGuardian::Stores::UserStore.reset_password('email')

        expect(result).to be true
      end

      it 'fails on invalid email' do
        allow_any_instance_of(ApiGuardian::Stores::UserStore).to receive(:find_by_email).and_return(nil)

        result = ApiGuardian::Stores::UserStore.reset_password('email')

        expect(result).to be false
      end
    end

    describe '.complete_reset_password' do
      it 'fails on missing user' do
        allow_any_instance_of(ApiGuardian::Stores::UserStore).to receive(:find_by_reset_password_token).and_return(nil)
        expect(ApiGuardian::Stores::UserStore.complete_reset_password({})).to be false
      end

      it 'fails if token doesn\'t match user email' do
        user = mock_model(ApiGuardian::User)
        expect(user).to receive(:email).and_return('bar')
        allow_any_instance_of(ApiGuardian::Stores::UserStore).to receive(:find_by_reset_password_token).and_return(user)

        expect { ApiGuardian::Stores::UserStore.complete_reset_password(email: 'foo') }.to(
          raise_error ApiGuardian::Errors::ResetTokenUserMismatchError
        )
      end

      it 'fails if token is expired' do
        user = mock_model(ApiGuardian::User)
        expect(user).to receive(:email).and_return('bar')
        expect(user).to receive(:reset_password_token_valid?).and_return(false)
        allow_any_instance_of(ApiGuardian::Stores::UserStore).to receive(:find_by_reset_password_token).and_return(user)

        expect { ApiGuardian::Stores::UserStore.complete_reset_password(email: 'bar') }.to(
          raise_error ApiGuardian::Errors::ResetTokenExpiredError
        )
      end

      it 'fails if the new password is missing' do
        user = mock_model(ApiGuardian::User)
        allow_any_instance_of(ApiGuardian::Stores::UserStore).to receive(:find_by_reset_password_token).and_return(user)
        expect(user).to receive(:email).and_return('foo')
        expect(user).to receive(:reset_password_token_valid?).and_return(true)
        expect(user).to receive(:password)
        expect_any_instance_of(ActionController::Parameters).to receive(:fetch).with(:password, nil).and_return(nil)
        expect { ApiGuardian::Stores::UserStore.complete_reset_password(ActionController::Parameters.new(email: 'foo')) }.to(
          raise_error ActiveRecord::RecordInvalid
        )
      end

      it 'resets on valid attributes' do
        user = mock_model(ApiGuardian::User)
        allow_any_instance_of(ApiGuardian::Stores::UserStore).to receive(:find_by_reset_password_token).and_return(user)
        expect(user).to receive(:email).and_return('foo')
        expect(user).to receive(:reset_password_token_valid?).and_return(true)
        expect_any_instance_of(ActionController::Parameters).to receive(:fetch).with(:password, nil).and_return('password')
        expect(user).to receive(:assign_attributes)
        expect(user).to receive(:save!)
        expect(user).to receive(:reset_password_token=)
        expect(user).to receive(:reset_password_sent_at=)
        expect(user).to receive(:save)

        attributes = ActionController::Parameters.new(
          email: 'foo',
          password: 'password',
          password_confirmation: 'password'
        )

        expect(ApiGuardian::Stores::UserStore.complete_reset_password(attributes)).to be true
        expect(user.reset_password_token).to be nil
        expect(user.reset_password_sent_at).to be nil
      end
    end

    describe '#check_password' do
      it 'fails unless password is present' do
        user = mock_model(ApiGuardian::User)

        expect{subject.check_password(user, {})}.to raise_error ApiGuardian::Errors::PasswordRequired
      end

      it 'fails if password is invalid' do
        user = mock_model(ApiGuardian::User)
        expect(ApiGuardian::Strategies::PasswordAuthentication).to(
          receive(:authenticate).and_return(nil)
        )

        expect{subject.check_password(user, {password: 'test'})}.to raise_error ApiGuardian::Errors::PasswordInvalid
      end
    end
  end
end
