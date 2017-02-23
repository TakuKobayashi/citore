class CreateExamQuestions < ActiveRecord::Migration[5.0]
  def change
    create_table :exam_questions do |t|
      t.integer :exam_examination_id, null: false
      t.integer :exam_explaination_id
      t.integer :answer_category, null: false, default: 0
      t.float :point, null: false, default: 0
      t.string :number_word, null: false, default: ""
      t.text :title
      t.text :body, null: false
      t.text :correct_answer, null: false
    end
    add_index :exam_questions, :exam_examination_id
    add_index :exam_questions, :exam_explaination_id
  end
end
