describe ApiGuardian::Configuration do
  # Methods
  describe 'methods' do
    describe '.validate_password_score=' do
      it 'fails unless a boolean is passed' do
        expect{subject.validate_password_score = 'a'}.to(
          raise_error(ApiGuardian::Configuration::ConfigurationError)
        )

        expect{subject.validate_password_score = []}.to(
          raise_error(ApiGuardian::Configuration::ConfigurationError)
        )

        expect{subject.validate_password_score = 0}.to(
          raise_error(ApiGuardian::Configuration::ConfigurationError)
        )

        expect{subject.validate_password_score = true}.not_to raise_error
        expect{subject.validate_password_score = false}.not_to raise_error
      end
    end

    describe '.minimum_password_score=' do
      it 'fails if the score is not between 0 and 4' do
        expect{subject.minimum_password_score = 'a'}.to(
          raise_error(ApiGuardian::Configuration::ConfigurationError)
        )

        expect{subject.minimum_password_score = -1}.to(
          raise_error(ApiGuardian::Configuration::ConfigurationError)
        )

        expect{subject.minimum_password_score = []}.to(
          raise_error(ApiGuardian::Configuration::ConfigurationError)
        )

        (0..4).each do |n|
          expect{subject.minimum_password_score = n}.not_to raise_error
        end
      end

      it 'warns when set less than 3' do
        expect_any_instance_of(::Logger).to(
          receive(:warn).with('[ApiGuardian] A password score of less than 3 is not recommended.')
        )

        subject.minimum_password_score = 2
      end
    end

    describe '.otp_header_name=' do
      it 'fails if the value is not a string' do
        expect{subject.otp_header_name = -1}.to(
          raise_error(ApiGuardian::Configuration::ConfigurationError)
        )

        expect{subject.otp_header_name = []}.to(
          raise_error(ApiGuardian::Configuration::ConfigurationError)
        )

        expect{subject.otp_header_name = 'a'}.not_to raise_error
      end
    end

    describe '.enable_2fa=' do
      it 'fails if the value is not a boolean' do
        expect{subject.enable_2fa = -1}.to(
          raise_error(ApiGuardian::Configuration::ConfigurationError)
        )

        expect{subject.enable_2fa = []}.to(
          raise_error(ApiGuardian::Configuration::ConfigurationError)
        )

        expect{subject.enable_2fa = true}.not_to raise_error
        expect{subject.enable_2fa = false}.not_to raise_error
      end
    end

    describe '.twilio_send_from=' do
      it 'fails if the provided number is invalid' do
        expect(Phony).to receive(:plausible?).and_return false
        expect{subject.twilio_send_from = 'test'}.to(
          raise_error(ApiGuardian::Configuration::ConfigurationError)
        )
      end
    end

    describe '.twilio_id' do
      it 'fails if the value is missing' do
        expect{subject.twilio_id}.to(
          raise_error(ApiGuardian::Configuration::ConfigurationError)
        )

        subject.twilio_id = 'test'

        expect{subject.twilio_id}.not_to raise_error
      end
    end

    describe '.twilio_token' do
      it 'fails if the value is missing' do
        expect{subject.twilio_token}.to(
          raise_error(ApiGuardian::Configuration::ConfigurationError)
        )

        subject.twilio_token = 'test'

        expect{subject.twilio_token}.not_to raise_error
      end
    end
  end
end
