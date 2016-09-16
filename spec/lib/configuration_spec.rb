describe ApiGuardian::Configuration do
  # Methods
  describe 'methods' do
    describe '.validate_password_score=' do
      it 'fails unless a boolean is passed' do
        expect { subject.validate_password_score = 'a' }.to(
          raise_error(ApiGuardian::Configuration::ConfigurationError)
        )

        expect { subject.validate_password_score = [] }.to(
          raise_error(ApiGuardian::Configuration::ConfigurationError)
        )

        expect { subject.validate_password_score = 0 }.to(
          raise_error(ApiGuardian::Configuration::ConfigurationError)
        )

        expect { subject.validate_password_score = true }.not_to raise_error
        expect { subject.validate_password_score = false }.not_to raise_error
      end
    end

    describe '.minimum_password_score=' do
      it 'fails if the score is not between 0 and 4' do
        expect { subject.minimum_password_score = 'a' }.to(
          raise_error(ApiGuardian::Configuration::ConfigurationError)
        )

        expect { subject.minimum_password_score = -1 }.to(
          raise_error(ApiGuardian::Configuration::ConfigurationError)
        )

        expect { subject.minimum_password_score = [] }.to(
          raise_error(ApiGuardian::Configuration::ConfigurationError)
        )

        (0..4).each do |n|
          expect { subject.minimum_password_score = n }.not_to raise_error
        end
      end

      it 'warns when set less than 3' do
        expect(ApiGuardian.logger).to(
          receive(:warn).with('A password score of less than 3 is not recommended.')
        )

        subject.minimum_password_score = 2
      end
    end

    describe '.otp_header_name=' do
      it 'fails if the value is not a string' do
        expect { subject.otp_header_name = -1 }.to(
          raise_error(ApiGuardian::Configuration::ConfigurationError)
        )

        expect { subject.otp_header_name = [] }.to(
          raise_error(ApiGuardian::Configuration::ConfigurationError)
        )

        expect { subject.otp_header_name = 'a' }.not_to raise_error
      end
    end

    describe '.enable_2fa=' do
      it 'fails if the value is not a boolean' do
        expect { subject.enable_2fa = -1 }.to(
          raise_error(ApiGuardian::Configuration::ConfigurationError)
        )

        expect { subject.enable_2fa = [] }.to(
          raise_error(ApiGuardian::Configuration::ConfigurationError)
        )

        expect { subject.enable_2fa = true }.not_to raise_error
        expect { subject.enable_2fa = false }.not_to raise_error
      end
    end

    describe '.available_2fa_methods=' do
      it 'fails if the value is not an array' do
        expect { subject.available_2fa_methods = 0 }.to(
          raise_error(ApiGuardian::Configuration::ConfigurationError)
        )

        expect { subject.available_2fa_methods = 'a' }.to(
          raise_error(ApiGuardian::Configuration::ConfigurationError)
        )

        expect { subject.available_2fa_methods = ['sms'] }.not_to raise_error
      end

      it 'fails if the value contains unavailable 2FA methods' do
        expect { subject.available_2fa_methods = ['sms'] }.not_to raise_error
        expect { subject.available_2fa_methods = ['voice'] }.not_to raise_error
        expect { subject.available_2fa_methods = ['google_auth'] }.not_to raise_error
        expect { subject.available_2fa_methods = ['email'] }.not_to raise_error
        expect { subject.available_2fa_methods = ['screaming'] }.to(
          raise_error(ApiGuardian::Configuration::ConfigurationError)
        )
      end
    end

    describe '.twilio_send_from=' do
      it 'fails if the provided number is invalid' do
        expect(Phony).to receive(:plausible?).and_return false
        expect { subject.twilio_send_from = 'test' }.to(
          raise_error(ApiGuardian::Configuration::ConfigurationError)
        )
      end
    end

    describe '.twilio_id' do
      it 'fails if the value is missing' do
        expect { subject.twilio_id }.to(
          raise_error(ApiGuardian::Configuration::ConfigurationError)
        )

        subject.twilio_id = 'test'

        expect { subject.twilio_id }.not_to raise_error
      end
    end

    describe '.twilio_token' do
      it 'fails if the value is missing' do
        expect { subject.twilio_token }.to(
          raise_error(ApiGuardian::Configuration::ConfigurationError)
        )

        subject.twilio_token = 'test'

        expect { subject.twilio_token }.not_to raise_error
      end
    end

    describe '.access_token_expires_in=' do
      it 'fails if the value is not a duration' do
        expect { subject.access_token_expires_in = 'a' }.to(
          raise_error(ApiGuardian::Configuration::ConfigurationError)
        )

        expect { subject.access_token_expires_in = 2 }.to(
          raise_error(ApiGuardian::Configuration::ConfigurationError)
        )

        expect { subject.access_token_expires_in = [] }.to(
          raise_error(ApiGuardian::Configuration::ConfigurationError)
        )

        expect { subject.access_token_expires_in = 2.hours }.not_to raise_error
        expect(subject.access_token_expires_in).to eq 2.hours
      end
    end

    describe '.jwt_encryption_method=' do
      it 'fails if the encryption method is invalid' do
        expect { subject.jwt_encryption_method = 'a' }.to(
          raise_error(ApiGuardian::Configuration::ConfigurationError)
        )

        expect { subject.jwt_encryption_method = nil }.to(
          raise_error(ApiGuardian::Configuration::ConfigurationError)
        )

        valid_methods = [
          :none, :hs256, :hs384, :hs512, :rs256, :rs384, :rs512, :es256, :es384, :es512
        ]

        valid_methods.each do |method|
          expect { subject.jwt_encryption_method = method }.not_to raise_error
        end
      end
    end

    describe '.client_password_reset_url=' do
      it 'fails if the value is not a valid URL' do
        expect { subject.client_password_reset_url = 'a' }.to(
          raise_error(ApiGuardian::Configuration::ConfigurationError)
        )

        expect { subject.client_password_reset_url = '//:asd.com' }.to(
          raise_error(ApiGuardian::Configuration::ConfigurationError)
        )

        expect { subject.client_password_reset_url = 'ttp//asd.net' }.to(
          raise_error(ApiGuardian::Configuration::ConfigurationError)
        )

        expect { subject.client_password_reset_url = 'http://test.com' }.not_to raise_error
      end
    end

    describe '.reuse_access_token=' do
      it 'fails if the value is not a boolean' do
        expect { subject.reuse_access_token = -1 }.to(
          raise_error(ApiGuardian::Configuration::ConfigurationError)
        )

        expect { subject.reuse_access_token = [] }.to(
          raise_error(ApiGuardian::Configuration::ConfigurationError)
        )

        expect { subject.reuse_access_token = true }.not_to raise_error
        expect { subject.reuse_access_token = false }.not_to raise_error
      end
    end

    describe '.allow_guest_authentication=' do
      it 'fails if the value is not a boolean' do
        expect { subject.allow_guest_authentication = -1 }.to(
          raise_error(ApiGuardian::Configuration::ConfigurationError)
        )

        expect { subject.allow_guest_authentication = [] }.to(
          raise_error(ApiGuardian::Configuration::ConfigurationError)
        )

        expect { subject.allow_guest_authentication = true }.not_to raise_error
        expect { subject.allow_guest_authentication = false }.not_to raise_error
      end
    end
  end
end

describe ApiGuardian::Configuration::Registration do
  describe 'methods' do
    describe '#add_config_option' do
      it 'adds attr_accessor to itself by key' do
        expect(subject).not_to have_attr_accessor(:test)

        subject.add_config_option :test

        expect(subject).to have_attr_accessor(:test)
      end
    end
  end
end
