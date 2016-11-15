class CreateCitoreDictionaries < ActiveRecord::Migration[5.0]
  def change
    create_table :citore_dictionaries do |t|
      t.string  :tweet_id_str, null: false
      t.integer :tweet_user_id, null: false, :limit => 8
      t.string  :tweet, null: false
      t.string  :tweet_reading, null: false
      t.text    :link_url
      t.timestamps
    end
    add_index :citore_dictionaries, :tweet_id_str, unique: true
    add_index :citore_dictionaries, :tweet_reading, unique: true
  end
end
