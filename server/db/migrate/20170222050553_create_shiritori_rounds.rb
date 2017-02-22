class CreateShiritoriRounds < ActiveRecord::Migration[5.0]
  def change
    create_table :shiritori_rounds do |t|
      t.integer :number, null: false, default: 1
      t.boolean :activate, null: false, default: true
      t.string :winner_user_type
      t.integer :winner_user_id
      t.timestamps
    end
  end
end
