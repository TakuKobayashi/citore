class CreateMoiVoiceLiveStreamComments < ActiveRecord::Migration[5.0]
  def change
    create_table :moi_voice_live_stream_comments do |t|
      t.integer :moi_voice_twitcas_user_id, null: false
      t.integer :moi_voice_live_stream_id, null: false
      t.text :comment
      t.timestamps
    end
    add_index :moi_voice_live_stream_comments, :moi_voice_twitcas_user_id, name: "moi_voice_live_stream_comment_user_id_index"
    add_index :moi_voice_live_stream_comments, :moi_voice_live_stream_id, name: "moi_voice_live_stream_comment_stream_index"
  end
end
