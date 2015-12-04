class CreateApiGuardianRolePermissions < ActiveRecord::Migration
  def change
    create_table :api_guardian_role_permissions, id: :uuid do |t|
      t.uuid :role_id
      t.uuid :permission_id
      t.boolean :granted, default: false

      t.timestamps null: false
    end
  end
end
