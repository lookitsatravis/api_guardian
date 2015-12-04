class CreateApiGuardianRoles < ActiveRecord::Migration
  def change
    create_table :api_guardian_roles, id: :uuid do |t|
      t.string :name
      t.boolean :default, default: false
      t.timestamps null: false
    end
  end
end
