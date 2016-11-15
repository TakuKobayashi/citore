class CreateVoices < ActiveRecord::Migration[5.0]
  def change
    create_table :voices do |t|
      t.string  :seed_type, null: false
      t.integer :seed_id, null: false
      t.string  :speacker_keyword, null: false
      t.string  :speech_file_name, null: false
      t.timestamps
    end
    add_index :voices, [:seed_type, :seed_id, :speacker_keyword], unique: true
  end
end
