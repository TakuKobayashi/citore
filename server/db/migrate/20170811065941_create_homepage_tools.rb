class CreateHomepageTools < ActiveRecord::Migration[5.1]
  def change
    create_table :homepage_tools do |t|
      t.string :title
      t.text :description
      t.string :path
      t.boolean :active, null: false, default: true
      t.datetime :pubulish_at, null: false
      t.timestamps
    end
    add_index :homepage_tools, :path
    add_index :homepage_tools, :pubulish_at
  end
end
