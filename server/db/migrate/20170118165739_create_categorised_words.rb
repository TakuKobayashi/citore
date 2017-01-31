class CreateCategorisedWords < ActiveRecord::Migration[5.0]
  def change
    create_table :categorised_words do |t|
      t.string :type, null: false
      t.integer :large_category, null: false, default: 0
      t.integer :medium_category, null: false, default: 0
      t.string :detail_category, null: false
      t.integer :degree, null: false, default: 0
      t.string :body, null: false
      t.string :from_url
    end
    add_index :categorised_words, [:large_category, :medium_category, :detail_category], name: "word_categories_index"
    add_index :categorised_words, :from_url
  end
end
