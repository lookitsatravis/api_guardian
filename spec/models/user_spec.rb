# frozen_string_literal: true

RSpec.describe ApiGuardian::User, type: :model do
  subject { create(:user) }

  # Relations
  context 'relations' do
    it { should belong_to(:role) }
    it { should have_many(:identities) }
  end

  # Validations
  context 'validations' do
    context 'email' do
      it { should validate_uniqueness_of(:email).allow_nil }

      context 'presence' do
        # Phone is not present
        it 'validates when phone_number is blank' do
          subject.phone_number = nil
          subject.phone_number_confirmed_at = nil
          subject.email = nil
          subject.email_confirmed_at = nil

          expect(subject).not_to be_valid

          subject.phone_number = '18005551234'

          expect(subject).to be_valid
        end
      end
    end

    context 'phone_number' do
      # FIXME: This validation test fails due to a bug in shoulda-matchers
      # https://github.com/thoughtbot/shoulda-matchers/issues/853
      # it { should validate_uniqueness_of(:phone_number).case_insensitive.allow_nil }

      it 'validates when email is blank' do
        subject.phone_number = nil
        subject.phone_number_confirmed_at = nil
        subject.email = nil
        subject.email_confirmed_at = nil

        expect(subject).not_to be_valid

        subject.email = '18005551234'

        expect(subject).to be_valid
      end
    end
    it { should validate_with ApiGuardian::Validators::PasswordLengthValidator }
    it { should validate_with ApiGuardian::Validators::PasswordScoreValidator }
  end

  # Delegates
  describe 'delegates' do
    it { should delegate_method(:can?).to(:role) }
    it { should delegate_method(:cannot?).to(:role) }
  end

  # Scopes
  describe 'scopes' do
  end

  # Methods
  context 'methods' do
    describe '#reset_password_token_valid?' do
      let!(:user) { create(:user) }

      it 'is invalid if token was sent more than 24 hours ago' do
        expect(user.reset_password_token_valid?).to be false

        user.reset_password_sent_at = 30.hours.ago

        expect(user.reset_password_token_valid?).to be false

        user.reset_password_sent_at = 8.hours.ago

        expect(user.reset_password_token_valid?).to be true
      end
    end

    describe '#enforce_email_case' do
      it 'ensures email is stored downcase on save' do
        user = create(:user, email: 'UPPERCASE@EXAMPLE.COM')

        expect(user.email).to eq 'uppercase@example.com'

        user2 = create(:user, email: 'MiXeDcAsE@eXaMpLe.CoM')

        expect(user2.email).to eq 'mixedcase@example.com'

        user3 = create(:user, email: 'lowercase@example.com')

        expect(user3.email).to eq 'lowercase@example.com'
      end
    end

    describe '#guest?' do
      it 'determines if a user is a guest based on email address' do
        user = create(:user, email: 'something@example.com')
        expect(user.guest?).to eq false

        user = create(:user, email: 'guest@application-guest.com')
        expect(user.guest?).to eq true
      end
    end
  end
end
