class CreateDatapoolAppearWords < ActiveRecord::Migration[5.1]
  def change
    create_table :datapool_appear_words do |t|
      t.integer :appear_count, null: false, default: 0
      t.string  :type
      t.string  :word, null: false
      t.string  :part, null: false
      t.string  :reading, null: false
      t.integer :sentence_count, null: false, default: 0
    end
    add_index :datapool_appear_words, [:word, :part], unique: true
    add_index :datapool_appear_words, :reading
  end
end
