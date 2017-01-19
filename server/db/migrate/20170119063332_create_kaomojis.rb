class CreateKaomojis < ActiveRecord::Migration[5.0]
  def change
    create_table :kaomojis do |t|
      t.string :category, null: false
      t.string :meaning, null: false
      t.string :body, null: false
      t.string :from
    end
    add_index :kaomojis, :category
    add_index :kaomojis, :meaning
  end
end
