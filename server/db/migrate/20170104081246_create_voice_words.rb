class CreateVoiceWords < ActiveRecord::Migration[5.0]
  def change
    create_table :voice_words do |t|
      t.string :from_type, null: false
      t.integer :from_id, null: false
      t.string :speaker_name, null: false
      t.string :file_name, null: false

      t.timestamps
    end
    add_index :voice_words, [:from_type, :from_id, :speaker_name], unique: true, name: "vioce_from_indexes"
  end
end
