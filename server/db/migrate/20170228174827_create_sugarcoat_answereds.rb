class CreateSugarcoatAnswereds < ActiveRecord::Migration[5.0]
  def change
    create_table :sugarcoat_answereds do |t|
      t.string :answer_user_type, null: false
      t.integer :answer_user_id, null: false
      t.text :input_word, null: false
      t.float :input_score, null: false, default: 0
      t.string :output_word, null: false
      t.float :output_score, null: false, default: 0
      t.timestamps
    end
    add_index :sugarcoat_answereds, [:answer_user_type, :answer_user_id], name: "sugarcoat_answered_user_index"
    add_index :sugarcoat_answereds, :input_score
    add_index :sugarcoat_answereds, :output_score
  end
end
