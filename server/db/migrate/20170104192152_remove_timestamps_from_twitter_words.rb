class RemoveTimestampsFromTwitterWords < ActiveRecord::Migration[5.0]
  def up
    remove_columns :twitter_words, :created_at, :updated_at
  end

  def down
    add_column :twitter_words, :created_at, :datetime
    add_column :twitter_words, :updated_at, :datetime
  end
end
