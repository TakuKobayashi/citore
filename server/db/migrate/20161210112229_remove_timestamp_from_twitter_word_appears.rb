class RemoveTimestampFromTwitterWordAppears < ActiveRecord::Migration[5.0]
  def up
    remove_columns :twitter_word_appears, :created_at, :updated_at
  end

  def down
    add_column :twitter_word_appears, :created_at, :datetime
    add_column :twitter_word_appears, :updated_at, :datetime
  end
end
