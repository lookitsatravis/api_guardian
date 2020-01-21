# frozen_string_literal: true

describe ApiGuardian::Strategies::Registration::Base do
  let(:klass) { ApiGuardian::Strategies::Registration::Base }

  describe 'methods' do
    describe '.allowed_api_parameters' do
      it 'adds each arg to params array' do
        klass.allowed_api_parameters :foo, :bar, :baz
        expect(klass.params.count).to eq 3
        expect(klass.params).to include(:foo)
        expect(klass.params).to include(:bar)
        expect(klass.params).to include(:baz)
      end
    end

    describe '.params' do
      it 'returns params class var' do
        expect(klass.params).to be_a Array
      end
    end

    describe '.add_config_option' do
      it 'forwards request to registration config class' do
        expect_any_instance_of(ApiGuardian::Configuration::Registration).to receive(:add_config_option).with(:foobar)
        klass.add_config_option(:foobar)
      end
    end

    describe '.providers' do
      it 'returns providers class var' do
        expect(klass.providers).to be_a Hash
      end
    end

    describe '.provides_registration_for' do
      it 'sets providers class var with instance by name' do
        expect(klass.providers.count).to eq 1 # default

        klass.provides_registration_for(:foo)

        expect(klass.providers).to be_a Hash
        expect(klass.providers.count).to eq 2
        expect(klass.providers[:foo]).to be_a klass
      end
    end

    describe '#validate' do
      it 'returns basic success validation' do
        result = subject.validate({})

        expect(result.succeeded).to eq true
        expect(result.error).to eq ''
      end
    end

    describe '#register' do
      it 'execute validation' do
        expect_any_instance_of(ApiGuardian::ValidationResult).to receive(:succeeded).and_return true

        expect { subject.register({}) }.not_to raise_error
      end

      it 'fails if validation fails' do
        expect_any_instance_of(ApiGuardian::ValidationResult).to receive(:succeeded).and_return false
        expect_any_instance_of(ApiGuardian::ValidationResult).to receive(:error).and_return 'test'

        expect { subject.register({}) }.to raise_error(
          ApiGuardian::Errors::RegistrationValidationFailed,
          'test'
        )
      end
    end

    describe '#params' do
      it 'returnes class params' do
        expect(ApiGuardian::Strategies::Registration::Base).to receive(:params)

        subject.params
      end
    end
  end
end
