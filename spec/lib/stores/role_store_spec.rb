# frozen_string_literal: true

describe ApiGuardian::Stores::RoleStore do
  # Methods
  describe 'methods' do
    describe '.default_role' do
      it 'should return the default role' do
        expect(ApiGuardian::Role).to receive(:default_role)

        ApiGuardian::Stores::RoleStore.default_role
      end
    end
  end
end
