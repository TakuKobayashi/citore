class CreateWikipediaArticleAppearWords < ActiveRecord::Migration[5.0]
  def change
    create_table :wikipedia_article_appear_words do |t|
      t.integer :wikipedia_article_id, null: false
      t.integer :appear_word_id, null: false
      t.integer :category, null: false
    end
    add_index :wikipedia_article_appear_words, [:wikipedia_article_id, :appear_word_id, :category], name: "article_appear_words_index"
  end
end
