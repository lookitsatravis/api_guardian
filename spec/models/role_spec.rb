# frozen_string_literal: true

RSpec.describe ApiGuardian::Role, type: :model do
  # Relations
  context 'relations' do
    it { should have_many(:users) }
    it { should have_many(:role_permissions) }
  end

  # Validations
  context 'validations' do
    it { should validate_presence_of :name }
    it { should validate_uniqueness_of :name }

    # TODO: Fix this
    # context 'default should be unique' do
    #   context 'if true' do
    #     before { subject.default = true }
    #     it { should validate_uniqueness_of :default }
    #   end
    #
    #   context 'unless false' do
    #     before { subject.default = false }
    #     it { should_not validate_uniqueness_of :default }
    #   end
    # end
  end

  # Delegates
  describe 'delegates' do
  end

  # Scopes
  describe 'scopes' do
    let!(:default_role) { create(:role, default: true) }
    let!(:non_default_role) { create(:role) }

    it '.default' do
      expect(ApiGuardian::Role.default.all).to eq [default_role]
    end
  end

  # Methods
  context 'methods' do
    describe '.default_role' do
      let!(:default_role) { create(:role, default: true) }
      let!(:non_default_role) { create(:role) }

      it 'should return default role' do
        expect(ApiGuardian::Role.default_role).to eq default_role
      end
    end

    describe '#can? and #cannot?' do
      let!(:role) { create(:role_with_permissions) }

      it 'errors on invalid permisson' do
        expect { role.can? 'invalid' }.to raise_error ApiGuardian::Errors::InvalidPermissionName
        expect { role.cannot? 'invalid' }.to raise_error ApiGuardian::Errors::InvalidPermissionName
      end

      context 'with array of permissions' do
        it 'is true if at least one permission is granted' do
          granted_perm1 = role.role_permissions.where(granted: true).first.permission
          granted_perm2 = role.role_permissions.where(granted: true).last.permission
          nongranted_perm1 = role.role_permissions.where(granted: false).first.permission
          nongranted_perm2 = role.role_permissions.where(granted: false).last.permission

          # multiple granted permissions
          expect(role.can?([granted_perm1.name, granted_perm2.name])).to be true
          expect(role.cannot?([granted_perm1.name, granted_perm2.name])).to be false

          # single granted permission
          expect(role.can?([granted_perm1.name, nongranted_perm1.name])).to be true
          expect(role.cannot?([granted_perm1.name, nongranted_perm1.name])).to be false

          # no granted permissions
          expect(role.can?([nongranted_perm1.name, nongranted_perm2.name])).to be false
          expect(role.cannot?([nongranted_perm1.name, nongranted_perm2.name])).to be true
        end
      end

      context 'with single permission' do
        it 'is true if permission is granted' do
          granted_perm = role.role_permissions.where(granted: true).first.permission
          nongranted_perm = role.role_permissions.where(granted: false).first.permission

          expect(role.can?(granted_perm.name)).to be true
          expect(role.cannot?(granted_perm.name)).to be false
          expect(role.can?(nongranted_perm.name)).to be false
          expect(role.cannot?(nongranted_perm.name)).to be true
        end
      end
    end

    describe '#permissions' do
      let!(:role) { create(:role_with_permissions) }

      it 'returns an array of granted permission names' do
        result = role.permissions

        perms = []
        role.role_permissions.each do |rp|
          perms.push rp.permission.name if rp.granted
        end

        expect(result).to eq perms
      end

      it 'returns only manage permission if it exists' do
        perm_read = create(:permission, name: 'user:read')
        perm_create = create(:permission, name: 'user:create')
        perm_manage = create(:permission, name: 'user:manage')

        role.role_permissions.create!(permission: perm_read, granted: true)
        role.role_permissions.create!(permission: perm_create, granted: true)
        role.role_permissions.create!(permission: perm_manage, granted: true)

        result = role.permissions

        expect(result).not_to include('user:read')
        expect(result).not_to include('user:create')
        expect(result).to include('user:manage')
      end
    end

    describe '#create_default_permissions' do
      let!(:role) { create(:role_with_permissions) }

      it 'should associate permissions that are not yet associated' do
        expect(role.role_permissions.count).to eq 5 # default from factory

        # When granted
        perm1 = create(:permission)

        role.create_default_permissions true

        expect(role.role_permissions.count).to eq 6
        expect(role.permissions).to include(perm1.name)

        # When not granted
        perm2 = create(:permission)

        role.create_default_permissions false

        expect(role.role_permissions.count).to eq 7
        expect(role.permissions).not_to include(perm2.name)
      end
    end

    describe '#add_permission' do
      let!(:role) { create(:role_with_permissions) }

      it 'errors on invalid permission' do
        expect { role.add_permission 'invalid' }.to raise_error ApiGuardian::Errors::InvalidPermissionName
      end

      it 'allows permission to be added by name' do
        expect(role.permissions.count).to eq 3

        create(:permission, name: 'user:read')
        role.add_permission('user:read')

        expect(role.permissions.count).to eq 4
        expect(role.permissions).to include('user:read')
      end

      it 'grants already added permission' do
        expect(role.permissions.count).to eq 3
        expect(role.role_permissions.count).to eq 5

        perm = create(:permission, name: 'user:read')
        role.role_permissions.create(permission: perm, granted: false)

        expect(role.permissions.count).to eq 3
        expect(role.role_permissions.count).to eq 6

        role.add_permission('user:read')

        expect(role.permissions.count).to eq 4
        expect(role.role_permissions.count).to eq 6
      end
    end

    describe '#remove_permission' do
      let!(:role) { create(:role_with_permissions) }

      it 'sets permission grant to false' do
        perm_name = role.permissions.first
        expect(role.permissions.count).to eq 3
        expect(role.role_permissions.count).to eq 5

        role.remove_permission(perm_name)

        expect(role.permissions.count).to eq 2
        expect(role.role_permissions.count).to eq 5
      end

      it 'can destroy permission altogether' do
        perm_name = role.permissions.first
        expect(role.permissions.count).to eq 3
        expect(role.role_permissions.count).to eq 5

        role.remove_permission(perm_name, true)

        expect(role.permissions.count).to eq 2
        expect(role.role_permissions.count).to eq 4
      end
    end
  end
end
