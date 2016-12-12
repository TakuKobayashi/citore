class CreateWikipediaThemes < ActiveRecord::Migration[5.0]
  def change
    create_table :wikipedia_themes do |t|
      t.string :title, null: false
      t.datetime :crawled_at
      t.timestamps
    end
    add_index :wikipedia_themes, :crawled_at
    add_index :wikipedia_themes, :title, unique: true
  end
end
