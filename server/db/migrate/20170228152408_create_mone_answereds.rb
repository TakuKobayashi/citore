class CreateMoneAnswereds < ActiveRecord::Migration[5.0]
  def change
    create_table :mone_answereds do |t|
      t.string :answer_user_type, null: false
      t.integer :answer_user_id, null: false
      t.text :input_word, null: false
      t.string :output_word, null: false
      t.timestamps
    end
    add_index :mone_answereds, [:answer_user_type, :answer_user_id], name: "mone_answered_user_index"
  end
end
