class AddColumnToAppearWords < ActiveRecord::Migration[5.0]
  def change
    add_column :appear_words, :reading, :string, null: false, default: ""
    remove_index :appear_words, [:word,:part]
    add_index :appear_words,  [:word,:part,:reading], unique: true
  end
end
