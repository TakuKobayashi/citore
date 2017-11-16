class CreateDatapoolAudioElements < ActiveRecord::Migration[5.1]
  def change
    create_table :datapool_audio_elements do |t|
      t.string :audio_type, null: false
      t.integer :audio_id, null: false
      t.integer :category, null: false, default: 0
      t.float :start, null: false, default: 0
      t.float :duration, null: false, default: 0
      t.float :confidence, null: false, default: 0
      t.text :others
      t.text :options
    end
    add_index :datapool_audio_elements, [:audio_type, :audio_id, :category], name: "datapool_audio_elements_index"
  end
end
