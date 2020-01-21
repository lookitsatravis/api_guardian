# frozen_string_literal: true

describe ApiGuardian::Policies::ApplicationPolicy do
  before(:each) do
    FactoryBot.create(:permission, name: 'user:create')
    FactoryBot.create(:permission, name: 'user:read')
    FactoryBot.create(:permission, name: 'user:update')
    FactoryBot.create(:permission, name: 'user:delete')
    FactoryBot.create(:permission, name: 'user:manage')
  end

  let(:current_user) { FactoryBot.create(:user) }

  subject { described_class }

  context 'defaults to disallowing' do
    let(:record) { FactoryBot.create(:user) }

    permissions :index? do
      it { is_expected.not_to permit(current_user, record) }
    end
  end

  context 'current_user has no permissions during' do
    let(:record) { FactoryBot.create(:user) }

    permissions :show?, :create?, :new?, :update?, :edit?, :destroy? do
      it { is_expected.not_to permit(current_user, record) }
    end
  end

  context 'current_user has read permissions during' do
    let(:record) { FactoryBot.create(:user) }

    permissions :show? do
      it { is_expected.not_to permit(current_user, record) }
    end

    permissions :show? do
      let(:current_user) do
        user = FactoryBot.create(:user)
        user.role.add_permission('user:read')
        user
      end
      it { is_expected.to permit(current_user, record) }
    end
  end

  context 'current_user has create permissions during' do
    let(:record) { FactoryBot.create(:user) }

    permissions :create? do
      it { is_expected.not_to permit(current_user, record) }
    end

    permissions :create? do
      let(:current_user) do
        user = FactoryBot.create(:user)
        user.role.add_permission('user:create')
        user
      end
      it { is_expected.to permit(current_user, record) }
    end
  end

  context 'current_user has update permissions during' do
    let(:record) { FactoryBot.create(:user) }

    permissions :update? do
      it { is_expected.not_to permit(current_user, record) }
    end

    permissions :update? do
      let(:current_user) do
        user = FactoryBot.create(:user)
        user.role.add_permission('user:update')
        user
      end
      it { is_expected.to permit(current_user, record) }
    end
  end

  context 'current_user has delete permissions during' do
    let(:record) { FactoryBot.create(:user) }

    permissions :destroy? do
      it { is_expected.not_to permit(current_user, record) }
    end

    permissions :destroy? do
      let(:current_user) do
        user = FactoryBot.create(:user)
        user.role.add_permission('user:delete')
        user
      end
      it { is_expected.to permit(current_user, record) }
    end
  end

  context 'current_user has manage permissions during' do
    let(:record) { FactoryBot.create(:user) }

    permissions :show? do
      it { is_expected.not_to permit(current_user, record) }
    end

    permissions :show?, :create?, :new?, :update?, :edit?, :destroy? do
      let(:current_user) do
        user = FactoryBot.create(:user)
        user.role.add_permission('user:manage')
        user
      end
      it { is_expected.to permit(current_user, record) }
    end
  end

  # permissions '.scope' do
  #   pending 'add some examples to (or delete) #{__FILE__}'
  # end
end
