class CreateExamUserSelects < ActiveRecord::Migration[5.0]
  def change
    create_table :exam_user_selects do |t|
      t.string :answer_user_type, null: false
      t.integer :answer_user_id, null: false
      t.string :current_exam_type, null: false
      t.boolean :activate, null: false, default: true
      t.datetime :started_at, null: false
      t.datetime :canceled_at
      t.timestamps
    end
    add_index :exam_user_selects, [:answer_user_type, :answer_user_id], name: "exam_user_select_user_index"
    add_index :exam_user_selects, [:started_at, :canceled_at], name: "exam_user_select_time_index"
  end
end
