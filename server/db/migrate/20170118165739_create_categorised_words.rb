class CreateCategorisedWords < ActiveRecord::Migration[5.0]
  def change
    create_table :categorised_words do |t|
      t.string :type, null: false
      t.integer :large_category, null: false, default: 0
      t.string :medium_category, null: false, default: ""
      t.string :detail_category, null: false
      t.text :body, null: false
      t.text :description
    end
    add_index :categorised_words, [:large_category, :medium_category, :detail_category], name: "word_categories_index"
  end
end
