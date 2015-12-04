class CreateApiGuardianPermissions < ActiveRecord::Migration
  def change
    create_table :api_guardian_permissions, id: :uuid do |t|
      t.string :name
      t.string :desc

      t.timestamps null: false
    end
  end
end
