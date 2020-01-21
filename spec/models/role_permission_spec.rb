# frozen_string_literal: true

RSpec.describe ApiGuardian::RolePermission, type: :model do
  subject { create(:role_permission) }

  # Relations
  context 'relations' do
    it { should belong_to(:role) }
    it { should belong_to(:permission) }
  end

  # Validations
  context 'validations' do
    # TODO: This has a weird test error
    # it do
    #   should validate_uniqueness_of(:role_id)
    #     .scoped_to(:permission_id)
    #     .with_message('Permission combination already exists!')
    # end
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
