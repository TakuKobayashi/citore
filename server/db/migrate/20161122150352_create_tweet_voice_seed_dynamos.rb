class CreateTweetVoiceSeedDynamos < ActiveRecord::Migration[5.0]
  def change
    create_table :tweet_voice_seed_dynamos do |t|

      t.timestamps
    end
  end
end
