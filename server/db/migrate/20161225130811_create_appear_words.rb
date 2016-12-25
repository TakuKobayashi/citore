class CreateAppearWords < ActiveRecord::Migration[5.0]
  def up
    AppearWord.connection.execute("ALTER TABLE tweet_appear_words RENAME TO #{AppearWord.table_name}")
  end

  def down
    AppearWord.connection.execute("ALTER TABLE #{AppearWord.table_name} RENAME TO tweet_appear_words")
  end
end
