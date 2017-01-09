class CreateLinebotEvents < ActiveRecord::Migration[5.0]
  def change
    create_table :linebot_events do |t|
      t.string :type, null: false
      t.string :message_type, null: false
      t.integer :linebot_followe_user_id, null: false
      t.string :line_user_id, null: false
      t.string :input_file_path
      t.string :output_file_path
      t.text :input_text
      t.text :output_text
      
      t.timestamps
    end
    add_index :linebot_events, [:linebot_followe_user_id, :type, :message_type], name: "linebot_event_indexes"
    add_index :linebot_events, :line_user_id
  end
end
