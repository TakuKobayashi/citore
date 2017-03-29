class CreateCharacterSerifMeta < ActiveRecord::Migration[5.0]
  def change
    create_table :character_serif_meta do |t|
      t.integer :character_serif_id, null: false
      t.string :title, null: false
      t.string :character_name, null: false
      t.integer :image_metum_id
      t.integer :reply_serif_id
    end

    add_index :character_serif_meta, :character_serif_id
    add_index :character_serif_meta, [:title, :character_name]
  end
end
