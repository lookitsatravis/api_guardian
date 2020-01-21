# frozen_string_literal: true

describe ApiGuardian::Strategies::Registration::Email do
  let(:base_klass) { ApiGuardian::Strategies::Registration::Base }
  let(:klass) { ApiGuardian::Strategies::Registration::Email }

  it 'registers email registration strategy' do
    expect(base_klass.providers[:email]).to be_a klass
  end

  it 'sets allowed API parameters' do
    [:email, :password, :password_confirmation].each do |f|
      expect(klass.params).to include(f)
    end
  end

  describe 'methods' do
    describe '#register' do
      it 'should create a user via UserStore' do
        attributes = {}
        user = mock_model(ApiGuardian::User)
        store = double(ApiGuardian::Stores::UserStore)
        expect(ApiGuardian::Stores::UserStore).to receive(:new).and_return(store)
        expect(store).to receive(:create).with(attributes).and_return(user)

        result = subject.register(ApiGuardian::Stores::UserStore, attributes)
        expect(result).to eq user
      end
    end
  end
end
