class CreateExamUserSelects < ActiveRecord::Migration[5.0]
  def change
    create_table :exam_user_selects do |t|
      t.string :answer_user_type, null: false
      t.integer :answer_user_id, null: false
      t.integer :exam_examination_id, null: false
      t.datetime :start_time, null: false
      t.timestamps
    end
    add_index :exam_user_selects, [:answer_user_type, :answer_user_id], name: "exam_user_select_user_index"
  end
end
