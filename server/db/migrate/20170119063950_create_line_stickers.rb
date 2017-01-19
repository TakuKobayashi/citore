class CreateLineStickers < ActiveRecord::Migration[5.0]
  def change
    create_table :line_stickers do |t|
      t.integer :stkid, null: false
      t.integer :stkpkgid, null: false
      t.string :meaning, null: false
      t.integer :stkver, null: false
    end
    add_index :line_stickers, :stkid
    add_index :line_stickers, :meaning
  end
end
