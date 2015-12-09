describe ApiGuardian::Policies::UserPolicy do
  before(:each) do
    FactoryGirl.create(:permission, name: 'user:create')
    FactoryGirl.create(:permission, name: 'user:read')
    FactoryGirl.create(:permission, name: 'user:update')
    FactoryGirl.create(:permission, name: 'user:delete')
    FactoryGirl.create(:permission, name: 'user:manage')
  end

  let(:current_user) { FactoryGirl.create(:user) }

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

    permissions :voice_otp? do
      it { is_expected.to permit(nil, nil) }
      it { is_expected.to permit(current_user, nil) }
      it { is_expected.to permit(nil, current_user) }
      it { is_expected.to permit(current_user, current_user) }
    end
  end

  # permissions '.scope' do
  #   pending 'add some examples to (or delete) #{__FILE__}'
  # end
end
