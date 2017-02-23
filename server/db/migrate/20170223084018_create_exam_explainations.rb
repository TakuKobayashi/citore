class CreateExamExplainations < ActiveRecord::Migration[5.0]
  def change
    create_table :exam_explainations do |t|
      t.integer :exam_examination_id, null: false
      t.string :number_word, null: false, default: ""
      t.string :large_category_name, null: false, default: ""
      t.text :title
      t.text :sub_title
      t.text :body, null: false
    end
    add_index :exam_explainations, :exam_examination_id
    add_index :exam_explainations, :large_category_name
  end
end
