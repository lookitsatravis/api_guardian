describe ApiGuardian::Configuration do
  # Methods
  describe 'methods' do
    describe '#validate_password_score=' do
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

    describe '#minimum_password_score=' do
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
  end
end
