# frozen_string_literal: true

describe ApiGuardian::Validators::PasswordLengthValidator do
  # Methods
  context 'methods' do
    describe '#validate' do
      it 'checks that a password\'s length matches configured value' do
        allow_any_instance_of(ApiGuardian::Configuration).to(
          receive(:minimum_password_length).and_return(8)
        )

        record = create(:user)

        expect(record.errors).not_to include(:password)

        record.password = '1234'
        subject.validate(record)

        expect(record.errors).to include(:password)

        record = create(:user)
        record.password = '12345678'
        subject.validate(record)

        expect(record.errors).not_to include(:password)
      end
    end
  end
end
