class CreateAccounts < ActiveRecord::Migration[5.1]
  def change
    create_table :accounts do |t|
      t.string :user_type, null: false
      t.integer :user_id, null: false
      t.string :type
      t.string :uid, null: false
      t.text :token
      t.text :token_secret
      t.datetime :expired_at
      t.text :options
      t.timestamps
    end
    add_index :accounts, :uid
    add_index :accounts, [:user_type, :user_id, :type], unique: true, name: "unique_user_and_id_accounts_index"
  end
end
