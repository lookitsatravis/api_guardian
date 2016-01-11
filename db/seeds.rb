# Roles
admin_role = ApiGuardian.configuration.role_class.create!(name: 'Super Admin')
user_role = ApiGuardian.configuration.role_class.create!(name: 'User', default: true)

# Permissions
ApiGuardian.configuration.permission_class.create!(name: 'user:create', desc: 'Ability to create User resource.')
ApiGuardian.configuration.permission_class.create!(name: 'user:read', desc: 'Ability to read User resource.')
ApiGuardian.configuration.permission_class.create!(name: 'user:update', desc: 'Ability to update User resource.')
ApiGuardian.configuration.permission_class.create!(name: 'user:delete', desc: 'Ability to delete User resource.')
ApiGuardian.configuration.permission_class.create!(name: 'user:manage', desc: 'Ability to manage User resource.')

ApiGuardian.configuration.permission_class.create!(name: 'role:create', desc: 'Ability to create Role resource.')
ApiGuardian.configuration.permission_class.create!(name: 'role:read', desc: 'Ability to read Role resource.')
ApiGuardian.configuration.permission_class.create!(name: 'role:update', desc: 'Ability to update Role resource.')
ApiGuardian.configuration.permission_class.create!(name: 'role:delete', desc: 'Ability to delete Role resource.')
ApiGuardian.configuration.permission_class.create!(name: 'role:manage', desc: 'Ability to manage Role resource.')

ApiGuardian.configuration.permission_class.create!(name: 'permission:create', desc: 'Ability to create Permission resource.')
ApiGuardian.configuration.permission_class.create!(name: 'permission:read', desc: 'Ability to read Permission resource.')
ApiGuardian.configuration.permission_class.create!(name: 'permission:update', desc: 'Ability to update Permission resource.')
ApiGuardian.configuration.permission_class.create!(name: 'permission:delete', desc: 'Ability to delete Permission resource.')
ApiGuardian.configuration.permission_class.create!(name: 'permission:manage', desc: 'Ability to manage Permission resource.')

admin_role.create_default_permissions true
user_role.create_default_permissions false

# Organization
org = ApiGuardian.configuration.organization_class.create!(name: 'Default')

# User
old_score = ApiGuardian.configuration.minimum_password_score
ApiGuardian.configuration.minimum_password_score = 0
ApiGuardian.configuration.user_class.create!(
  first_name: 'Test', last_name: 'User', email: 'test@example.com',
  password: 'password', password_confirmation: 'password', role: admin_role,
  active: true, email_confirmed_at: DateTime.now.utc, organization_id: org.id
)
ApiGuardian.configuration.minimum_password_score = old_score
