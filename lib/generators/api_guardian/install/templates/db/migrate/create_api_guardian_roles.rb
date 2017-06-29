class CreateApiGuardianRoles < ActiveRecord::Migration[5.0]
  def change
    create_table :api_guardian_roles, id: :uuid do |t|
      t.string :name
      t.boolean :default, default: false
      t.timestamps null: false
    end
  end
end
