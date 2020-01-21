# frozen_string_literal: true

RSpec.describe ApiGuardian::Identity, type: :model do
  subject { create(:identity) }

  # Relations
  context 'relations' do
    it { should belong_to(:user) }
  end

  # Validations
  context 'validations' do
    it { should validate_presence_of(:provider) }
    it { should validate_presence_of(:provider_uid) }
    it do
      should validate_uniqueness_of(:provider_uid)
        .scoped_to(:provider)
        .with_message('UID already exists for this provider.')
    end
  end

  # Delegates
  describe 'delegates' do
  end

  # Scopes
  describe 'scopes' do
  end

  # Methods
  context 'methods' do
  end
end
