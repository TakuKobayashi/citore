class CreateCategorisedWords < ActiveRecord::Migration[5.0]
  def change
    create_table :categorised_words do |t|

      t.timestamps
    end
  end
end
