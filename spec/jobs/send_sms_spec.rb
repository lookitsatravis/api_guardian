describe ApiGuardian::Jobs::SendSms do
  # Methods
  describe 'methods' do
    describe '#perform' do
      it 'logs error if user has no phone number' do
        user = mock_model(ApiGuardian::User)
        expect(user).to receive(:phone_number).and_return('')
        expect(Rails.logger).to receive(:error).with '[ApiGuardian] User does not have a confirmed phone number! Cannot send OTP.'

        subject.perform(user, 'I love scotch.')
      end

      it 'logs error if user\'s number is not confirmed' do
        example_number = '12345'
        user = mock_model(ApiGuardian::User)
        expect(user).to receive(:phone_number).and_return(example_number)
        expect(user).to receive(:phone_number_confirmed_at).and_return(nil)

        expect(Rails.logger).to receive(:error).with '[ApiGuardian] User does not have a confirmed phone number! Cannot send OTP.'

        subject.perform(user, 'I love scotch.')
      end

      it 'sends message via Twilio' do
        example_number = '54321'
        example_confirmed = DateTime.now.utc
        user = mock_model(ApiGuardian::User)
        ApiGuardian.configuration.twilio_send_from = '18009876543'
        mock_client = FakeSMS.new('foo', 'bar')

        expect(user).to receive(:phone_number).twice.and_return(example_number)
        expect(user).to receive(:phone_number_confirmed_at).and_return(example_confirmed)
        expect(ApiGuardian).to receive(:twilio_client).and_return(mock_client)
        expect(mock_client).to receive(:create).with(
          from: '18009876543',
          to: '54321',
          body: 'I love scotch.'
        )

        subject.perform(user, 'I love scotch.')
      end
    end
  end
end
