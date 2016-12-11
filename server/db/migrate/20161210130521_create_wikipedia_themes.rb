class CreateWikipediaThemes < ActiveRecord::Migration[5.0]
  def change
    create_table :wikipedia_themes do |t|
      t.string :title, null: false
      t.integer :twitter_word_id, null: false
      t.timestamps
    end
  end
end
