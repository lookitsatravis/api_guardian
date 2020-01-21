# frozen_string_literal: true

describe ApiGuardian::Strategies::Authentication::Guest do
  let(:klass) { ApiGuardian::Strategies::Authentication::Guest }

  # Methods
  describe 'methods' do
    describe '#authenticate' do
      it 'should fail if guest authentication is disabled' do
        RSpec::Expectations.configuration.warn_about_potential_false_positives = false

        ApiGuardian.configuration.allow_guest_authentication = false

        expect { klass.new.authenticate }.to raise_error ApiGuardian::Errors::GuestAuthenticationDisabled

        ApiGuardian.configuration.allow_guest_authentication = true

        expect { klass.new.authenticate }.not_to raise_error ApiGuardian::Errors::GuestAuthenticationDisabled

        RSpec::Expectations.configuration.warn_about_potential_false_positives = true
      end

      it 'should authenticate a user anonymously' do
        create(:role, default: true)
        ApiGuardian.configuration.allow_guest_authentication = true
        result = klass.new.authenticate
        expect(result).to be_a ApiGuardian.configuration.user_class
        expect(result.guest?).to eq true
      end
    end
  end
end
