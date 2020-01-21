# frozen_string_literal: true

RSpec.describe ApiGuardian::Permission, type: :model do
  subject { create(:permission) }

  # Relations
  context 'relations' do
    it { should have_many(:role_permissions) }
    it { should have_many(:roles) }
  end

  # Validations
  context 'validations' do
    it { should validate_presence_of :name }
    it { should validate_presence_of :desc }
    it { should validate_uniqueness_of :name }
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
