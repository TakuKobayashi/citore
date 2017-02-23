class CreateExamExaminations < ActiveRecord::Migration[5.0]
  def change
    create_table :exam_examinations do |t|
      t.string :type, null: false
      t.string :title, null: false, default: ""
      t.integer :version, null: false, default: 0
      t.datetime :implementation_time, null: false
    end
    add_index :exam_examinations, :implementation_time
  end
end
