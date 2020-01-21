# frozen_string_literal: true

describe ApiGuardian::Helpers do
  describe 'methods' do
    describe '.email_address?' do
      it 'should match email addresses' do
        expect(ApiGuardian::Helpers.email_address?('test')).to eq false
        expect(ApiGuardian::Helpers.email_address?('test.test')).to eq false
        expect(ApiGuardian::Helpers.email_address?('test@test')).to eq true
        expect(ApiGuardian::Helpers.email_address?('test@test.com')).to eq true
      end
    end

    describe '.phone_number?' do
      it 'should only match phone numbers in +NNNNN format' do
        expect(ApiGuardian::Helpers.phone_number?('(888) 555-1234')).to eq false
        expect(ApiGuardian::Helpers.phone_number?('8885551234')).to eq false
        expect(ApiGuardian::Helpers.phone_number?('+8885551234')).to eq true
      end
    end
  end
end
