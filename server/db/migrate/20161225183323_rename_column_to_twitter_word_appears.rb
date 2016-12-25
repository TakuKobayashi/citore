class RenameColumnToTwitterWordAppears < ActiveRecord::Migration[5.0]
  def change
    rename_column :twitter_word_appears, :tweet_appear_word_id, :appear_word_id
  end
end
