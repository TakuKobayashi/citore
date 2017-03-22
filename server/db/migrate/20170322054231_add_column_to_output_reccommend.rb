class AddColumnToOutputReccommend < ActiveRecord::Migration[5.0]
  def change
    add_column :spotgacha_output_recommends, :opentime, :string, null: false, default: ""
    add_column :spotgacha_output_recommends, :holiday, :string, null: false, default: ""
    add_column :spotgacha_output_recommends, :page_number, :integer, null: false, default: 0
  end
end
