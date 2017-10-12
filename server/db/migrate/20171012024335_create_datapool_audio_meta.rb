class CreateDatapoolAudioMeta < ActiveRecord::Migration[5.1]
  def change
    create_table :datapool_audio_meta do |t|
      t.string :type
      t.integer :file_genre, null: false, default: 0
      t.string :title, null: false
      t.string :original_filename
      t.string :origin_src, null: false
      t.text :query
      t.text :options
    end
    add_index :datapool_audio_meta, :title
    add_index :datapool_audio_meta, :origin_src
  end
end
