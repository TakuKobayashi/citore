class RemoveTimestampFromTwitterWordAppears < ActiveRecord::Migration[5.0]
  def up
    remove_columns :tweet_appear_words, :created_at, :updated_at
  end

  def down
    add_column :tweet_appear_words, :created_at, :datetime
    add_column :tweet_appear_words, :updated_at, :datetime
  end
end
