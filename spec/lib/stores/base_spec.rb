# frozen_string_literal: true

describe ApiGuardian::Stores::Base do
  subject { ApiGuardian::Stores::Base.new(scope) }

  let(:scope) { double(ApiGuardian::Policies::ApplicationPolicy::Scope) }

  # Delegates
  describe 'delegates' do
    it { should delegate_method(:new).to(:resource_class) }
  end

  # Methods
  describe 'methods' do
    # using the user model to test the base store
    let(:user) { double(ApiGuardian::User) }

    before(:each) do
      allow_any_instance_of(ApiGuardian::Stores::Base).to receive(:resource_class).and_return(user)
    end

    describe '#set_policy_scope' do
      it 'allows updating of policy scope' do
        expect(subject.scope).to eq scope

        subject.set_policy_scope nil

        expect(subject.scope).to eq nil
      end
    end

    describe '#all' do
      it 'returns objects via scope' do
        expect(scope).to receive(:all)
        subject.all
      end
    end

    describe '#paginate' do
      context 'returns objects via scope with pagination' do
        it 'without arguments' do
          expect(scope).to receive(:page).with(1).and_return(scope)
          expect(scope).to receive(:per).with(25)

          subject.paginate
        end

        it 'with arguments' do
          expect(scope).to receive(:page).with(10).and_return(scope)
          expect(scope).to receive(:per).with(50)

          subject.paginate(10, 50)
        end
      end
    end

    describe '#find' do
      it 'errors on missing record' do
        expect(user).to receive(:find).and_return(nil)

        expect { subject.find(1) }.to raise_error ActiveRecord::RecordNotFound
      end

      it 'returns record if found' do
        a_user = double(ApiGuardian::User)
        expect(user).to receive(:find).and_return(a_user)

        result = subject.find(1)

        expect(result).to eq a_user
      end
    end

    describe '#save' do
      it 'saves a record' do
        a_user = instance_double(ApiGuardian::User)
        expect(a_user).to receive(:save!)

        subject.save(a_user)
      end
    end

    describe '#create' do
      it 'errors on invalid record' do
        attributes = {}
        new_user = mock_model(ApiGuardian::User)
        expect(new_user).to receive(:valid?).and_return(false)
        expect(user).to receive(:new).with(attributes).and_return(new_user)

        expect { subject.create(attributes) }.to raise_error ActiveRecord::RecordInvalid
      end

      it 'creates a record' do
        attributes = {}
        new_user = mock_model(ApiGuardian::User)
        expect(new_user).to receive(:valid?).and_return(true)
        expect(user).to receive(:new).with(attributes).and_return(new_user)
        expect(subject).to receive(:save).with(new_user)

        result = subject.create(attributes)

        expect(result).to eq new_user
      end
    end

    describe '#update' do
      it 'updates a record' do
        attributes = {}
        a_user = instance_double(ApiGuardian::User)
        expect(a_user).to receive(:update_attributes!).with(attributes)

        subject.update(a_user, attributes)
      end
    end

    describe '#destroy' do
      it 'destroys a record' do
        a_user = instance_double(ApiGuardian::User)
        expect(a_user).to receive(:destroy!)

        subject.destroy(a_user)
      end
    end
  end
end
