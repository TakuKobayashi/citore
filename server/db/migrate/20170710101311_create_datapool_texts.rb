class CreateDatapoolTexts < ActiveRecord::Migration[5.1]
  def change
    create_table :datapool_texts do |t|
      t.string :type
      t.text :body, null: false
      t.string :from_url
    end
    add_index :datapool_texts, :from_url
  end
end
