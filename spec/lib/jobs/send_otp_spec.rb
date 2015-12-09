describe ApiGuardian::Jobs::SendOtp do
  # Methods
  describe 'methods' do
    describe '#perform' do
      it 'with otp_enabled disabled does nothing' do
        user = mock_model(ApiGuardian::User)
        expect(user).to receive(:otp_enabled?).and_return(false)

        subject.perform(user)
      end

      context 'with otp_enabled' do
        let(:user) { mock_model(ApiGuardian::User) }
        let(:mock_client) { FakeSMS.new('foo', 'bar') }
        let(:mock_voice_client) { FakeVoice.new('foo', 'bar') }
        let(:to_number) { '18005554321' }
        let(:from_number) { '18885551234' }
        let(:otp_code) { '0101' }

        before(:each) do
          expect(user).to receive(:otp_enabled?).and_return(true)
          ApiGuardian.configuration.twilio_send_from = from_number
        end

        context 'can send via SMS' do
          before(:each) do
            expect(user).to receive(:otp_method).and_return('sms')
          end

          it 'catches raised StandardErrors' do
            expect(user).to receive(:otp_code).and_return(otp_code)
            expect(ApiGuardian).to receive(:twilio_client).and_raise('oops')
            expect(Rails.logger).to receive(:warn).with "[ApiGuardian] Could not connect to Twilio! oops"
            subject.perform(user, true)
          end

          it 'executes when forced' do
            expect(user).to receive(:phone_number).and_return(to_number)
            expect(user).to receive(:otp_code).and_return(otp_code)
            expect(ApiGuardian).to receive(:twilio_client).and_return(mock_client)
            expect(mock_client).to receive(:create).with(
              from: from_number,
              to: to_number,
              body: "#{otp_code} is your authentication code."
            )

            subject.perform(user, true)
          end

          context 'executes when user can receive SMS' do
            it 'fails if user has no phone number' do
              expect(user).to receive(:phone_number).and_return('')
              expect(Rails.logger).to receive(:error).with '[ApiGuardian] User does not have a confirmed phone number! Cannot send OTP.'
              subject.perform(user)
            end

            it 'fails if user\'s phone number is not confirmed' do
              expect(user).to receive(:phone_number).and_return(to_number)
              expect(user).to receive(:phone_number_confirmed_at).and_return(nil)
              expect(Rails.logger).to receive(:error).with '[ApiGuardian] User does not have a confirmed phone number! Cannot send OTP.'
              subject.perform(user)
            end

            it 'sends message via Twilio' do
              expect(user).to receive(:phone_number).twice.and_return(to_number)
              expect(user).to receive(:phone_number_confirmed_at).and_return(DateTime.now)
              expect(user).to receive(:otp_code).and_return(otp_code)
              expect(ApiGuardian).to receive(:twilio_client).and_return(mock_client)
              expect(mock_client).to receive(:create).with(
                from: from_number,
                to: to_number,
                body: "#{otp_code} is your authentication code."
              )

              subject.perform(user)
            end
          end
        end

        context 'can send via voice' do
          before(:each) do
            expect(user).to receive(:otp_method).and_return('voice')
            ApiGuardian::Engine.routes.default_url_options[:host] = 'http://example.com'
          end

          it 'catches raised StandardErrors' do
            expect(ApiGuardian).to receive(:twilio_client).and_raise('oops')
            expect(Rails.logger).to receive(:warn).with "[ApiGuardian] Could not connect to Twilio! oops"
            subject.perform(user, true)
          end

          it 'executes when forced' do
            expect(user).to receive(:phone_number).and_return(to_number)
            expect(ApiGuardian).to receive(:twilio_client).and_return(mock_voice_client)
            expect(mock_voice_client).to receive(:create).with(
              from: from_number,
              to: to_number,
              url: ApiGuardian::Engine.routes.url_helpers.voice_otp_user_url(user)
            )

            subject.perform(user, true)
          end

          context 'executes when user can receive voice call' do
            it 'fails if user has no phone number' do
              expect(user).to receive(:phone_number).and_return('')
              expect(Rails.logger).to receive(:error).with '[ApiGuardian] User does not have a confirmed phone number! Cannot send OTP.'
              subject.perform(user)
            end

            it 'fails if user\'s phone number is not confirmed' do
              expect(user).to receive(:phone_number).and_return(to_number)
              expect(user).to receive(:phone_number_confirmed_at).and_return(nil)
              expect(Rails.logger).to receive(:error).with '[ApiGuardian] User does not have a confirmed phone number! Cannot send OTP.'
              subject.perform(user)
            end

            it 'initiate call via Twilio' do
              expect(user).to receive(:phone_number).twice.and_return(to_number)
              expect(user).to receive(:phone_number_confirmed_at).and_return(DateTime.now)
              expect(ApiGuardian).to receive(:twilio_client).and_return(mock_voice_client)
              expect(mock_voice_client).to receive(:create).with(
                from: from_number,
                to: to_number,
                url: ApiGuardian::Engine.routes.url_helpers.voice_otp_user_url(user)
              )

              subject.perform(user)
            end
          end
        end

        it 'can send via email' do
          expect(user).to receive(:otp_method).and_return('email')
          mock_delivery = instance_double(ActionMailer::MessageDelivery)
          expect(ApiGuardian::Mailers::Mailer).to receive(:one_time_password).with(user).and_return(mock_delivery)
          expect(mock_delivery).to receive(:deliver_later)
          subject.perform(user)
        end

        it 'can handle google_auth' do
          expect(user).to receive(:otp_method).and_return('google_auth')
          expect(Rails.logger).to receive(:info).with '[ApiGuardian] User will provide code from Google Auth app'
          subject.perform(user)
        end

        it 'logs error for all other cases' do
          expect(user).to receive(:otp_method).and_return('blah')
          expect(Rails.logger).to receive(:error).with "[ApiGuardian] No valid OTP send methods for user #{user.id}!"
          subject.perform(user)
        end
      end
    end
  end
end
