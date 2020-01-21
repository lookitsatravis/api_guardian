class CreateApiGuardianUsers < ActiveRecord::Migration[5.0]
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
      t.string :otp_secret_key
      t.boolean :otp_enabled, default: false
      t.string :otp_method, default: 'sms'

      t.timestamps null: false
    end

    add_index :api_guardian_users, :email, unique: true, using: :btree
    add_index :api_guardian_users, :reset_password_token, unique: true, using: :btree
    add_index :api_guardian_users, :role_id, using: :btree
  end
end
