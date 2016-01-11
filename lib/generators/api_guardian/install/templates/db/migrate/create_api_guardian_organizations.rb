class CreateApiGuardianOrganizations < ActiveRecord::Migration
  def change
    create_table :api_guardian_organizations, id: :uuid do |t|
      t.string :name
      t.boolean :active, default: false

      t.timestamps null: false
    end
  end
end
