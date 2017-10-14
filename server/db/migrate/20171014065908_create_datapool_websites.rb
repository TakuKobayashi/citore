class CreateDatapoolWebsites < ActiveRecord::Migration[5.1]
  def change
    create_table :datapool_websites do |t|
      t.string :type
      t.string :title, null: false
      t.string :origin_src, null: false
      t.text :query
      t.text :options
    end

    add_index :datapool_websites, :title
    add_index :datapool_websites, :origin_src
  end
end
