class CreateSugarcoatSeeds < ActiveRecord::Migration[5.0]
  def change
    create_table :sugarcoat_seeds do |t|

      t.timestamps
    end
  end
end
