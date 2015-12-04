RSpec.describe ApiGuardian::User, type: :model do
  subject { create(:user) }

  # Relations
  context 'relations' do
    it { should belong_to(:role) }
  end

  # Validations
  context 'validations' do
    it { should validate_presence_of :email }
    it { should validate_uniqueness_of :email }
    it { should validate_length_of :password }
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
  end
end
