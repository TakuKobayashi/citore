class CreateTwitterBots < ActiveRecord::Migration[5.0]
  def change
    create_table :twitter_bots do |t|
      t.string :type, null: false
      t.integer :action, null: false
      t.string :action_value, null: false
      t.string :action_resource_path
      t.string :action_id, null: false
      t.datetime :action_time, null: false
      t.integer :action_from_id
    end

    add_index :twitter_bots, [:type, :action]
    add_index :twitter_bots, :action_id
    add_index :twitter_bots, :action_from_id
  end
end
