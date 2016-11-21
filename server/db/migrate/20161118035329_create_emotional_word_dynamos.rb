class CreateEmotionalWordDynamos < ActiveRecord::Migration[5.0]
  def change
    create_table :emotional_word_dynamos do |t|

      t.timestamps
    end
  end
end
