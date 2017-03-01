class CreateCitoreEroticImages < ActiveRecord::Migration[5.0]
  def change
    create_table :citore_erotic_images do |t|
      t.string :keyword, null: false
      t.string :file_name, null: false
      t.timestamps
    end
    add_index :citore_erotic_images, :keyword
  end
end
