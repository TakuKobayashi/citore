class CreateBannosamaGreets < ActiveRecord::Migration[5.1]
  def change
    create_table :bannosama_greets do |t|
      t.integer :from_user_id
      t.integer :to_user_id
      t.integer :state, null: false, default: 0
      t.text :message
      t.integer :theme, null: false, default: 0
      t.timestamps
    end

    add_index :bannosama_greets, :from_user_id
    add_index :bannosama_greets, :to_user_id
  end
end
