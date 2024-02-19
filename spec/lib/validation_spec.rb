# frozen_string_literal: true

describe ApiGuardian::ValidationResult do
  it { should have_attr_reader(:succeeded) }
  it { should have_attr_reader(:error) }

  describe 'methods' do
    describe '#initialize' do
      it 'should set succeeded and error' do
        subject = ApiGuardian::ValidationResult.new

        expect(subject.succeeded).to eq true
        expect(subject.error).to eq ''

        subject = ApiGuardian::ValidationResult.new(false)

        expect(subject.succeeded).to eq false
        expect(subject.error).to eq ''

        subject = ApiGuardian::ValidationResult.new(true, 'test')

        expect(subject.succeeded).to eq true
        expect(subject.error).to eq 'test'
      end
    end
  end
end
