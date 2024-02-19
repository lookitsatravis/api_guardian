# frozen_string_literal: true

describe ApiGuardian::Policies::UserPolicy do
  before(:each) do
    FactoryBot.create(:permission, name: 'user:create')
    FactoryBot.create(:permission, name: 'user:read')
    FactoryBot.create(:permission, name: 'user:update')
    FactoryBot.create(:permission, name: 'user:delete')
    FactoryBot.create(:permission, name: 'user:manage')
  end

  let(:current_user) { FactoryBot.create(:user) }

  subject { described_class }

  context 'when current_user and user match for' do
    permissions :show?, :update?, :edit?, :add_phone?, :verify_phone? do
      let(:record) { current_user }
      it { is_expected.to permit(current_user, record) }
    end

    permissions :create?, :new?, :destroy? do
      let(:record) { current_user }
      it { is_expected.not_to permit(current_user, record) }
    end
  end

  # permissions '.scope' do
  #   pending 'add some examples to (or delete) #{__FILE__}'
  # end
end
