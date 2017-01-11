class RemoveColumnsTimestampToAppearWords < ActiveRecord::Migration[5.0]
  def up
    remove_columns :appear_words, :created_at, :updated_at
  end

  def down
    add_column :appear_words, :created_at, :datetime
    add_column :appear_words, :updated_at, :datetime
  end
end
