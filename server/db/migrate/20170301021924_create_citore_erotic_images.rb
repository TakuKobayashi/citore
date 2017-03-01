class CreateCitoreEroticImages < ActiveRecord::Migration[5.0]
  def change
    create_table :citore_erotic_images do |t|
      t.string :keyword, null: false
      t.string :file_name
      t.string :url
      t.string :preview_file_name
      t.string :preview_url
      t.timestamps
    end
    add_index :citore_erotic_images, :keyword
  end
end
