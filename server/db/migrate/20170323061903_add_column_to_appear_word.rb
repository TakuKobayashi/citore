class AddColumnToAppearWord < ActiveRecord::Migration[5.0]
  def change
    add_column :appear_words, :sentence_count, :integer, null: false, default: 0
  end
end
