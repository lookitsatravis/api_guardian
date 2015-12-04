class CreateApiGuardianUsers < ActiveRecord::Migration
  def change
    create_table :api_guardian_users, id: :uuid do |t|
      t.string :first_name
      t.string :last_name
      t.string :email
      t.datetime :email_confirmed_at
      t.string :phone_number
      t.datetime :phone_number_confirmed_at
      t.string :password_digest, null: false
      t.boolean :active, default: false
      t.uuid :role_id, null: false
      t.string :reset_password_token
      t.datetime :reset_password_sent_at
      t.datetime :deleted_at

      t.timestamps null: false
    end

    add_index 'api_guardian_users', ['deleted_at'], name: 'index_api_guardian_users_on_deleted_at', using: :btree
    add_index 'api_guardian_users', ['email'], name: 'index_api_guardian_users_on_email', unique: true, using: :btree
    add_index 'api_guardian_users', ['reset_password_token'], name: 'index_api_guardian_users_on_reset_password_token', unique: true, using: :btree
    add_index 'api_guardian_users', ['role_id'], name: 'index_api_guardian_users_on_role_id', using: :btree
  end
end
