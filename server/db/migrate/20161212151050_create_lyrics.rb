class CreateLyrics < ActiveRecord::Migration[5.0]
  def change
    create_table :lyrics do |t|
      t.string :title, null: false
      t.string :artist_name, null: false
      t.string :word_by
      t.string :music_by
      t.text :body, null: false
      t.timestamps
    end
    add_index :lyrics, :title
    add_index :lyrics, :artist_name
  end
end
