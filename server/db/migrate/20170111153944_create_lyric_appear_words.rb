class CreateLyricAppearWords < ActiveRecord::Migration[5.0]
  def change
    create_table :lyric_appear_words do |t|
      t.integer :lyric_id, null: false
      t.integer :appear_word_id, null: false
    end
    add_index :lyric_appear_words, [:lyric_id, :appear_word_id], name: "lyric_appear_words_index"
  end
end
