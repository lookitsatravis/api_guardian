class CreateApiGuardianIdentities < ActiveRecord::Migration
  def change
    create_table :api_guardian_identities, id: :uuid do |t|
      t.string :provider, null: false
      t.string :provider_uid, null: false
      t.json :tokens, null: false
      t.uuid :user_id, null: false
      t.timestamps null: false
    end

    add_index :api_guardian_identities, :user_id, using: :btree
  end
end
