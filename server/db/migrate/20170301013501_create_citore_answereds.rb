class CreateCitoreAnswereds < ActiveRecord::Migration[5.0]
  def change
    create_table :citore_answereds do |t|
      t.string :answer_user_type, null: false
      t.integer :answer_user_id, null: false
      t.text :input_word, null: false
      t.string :output_word, null: false
      t.integer :voice_id
      t.integer :image_id
      t.timestamps
    end

    add_index :citore_answereds, [:answer_user_type, :answer_user_id], name: "citore_answered_user_index"
  end
end
