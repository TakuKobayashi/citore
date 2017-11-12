class CreateHackathonArstudio2017Resources < ActiveRecord::Migration[5.1]
  def change
    create_table :hackathon_arstudio2017_resources do |t|
      t.integer :category, null: false, default: 0
      t.integer :mode, null: false, default: 0
      t.string :url, null: false
      t.text :original_filename, null: false
      t.text :options
      t.timestamps
    end
  end
end
