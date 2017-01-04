class CreateVoiceWords < ActiveRecord::Migration[5.0]
  def change
    create_table :voice_words do |t|
      t.string :word_type, null: false
      t.integer :word_id, null: false
      t.string :speaker_name, null: false
      t.string :file_name, null: false

      t.timestamps
    end
    add_index :voice_words, [:word_type, :word_id, :speaker_name], unique: true, name: "vioce_word_indexes"
  end
end
