class CreateDatapoolTrackResources < ActiveRecord::Migration[5.1]
  def change
    create_table :datapool_track_resources do |t|
      t.string :resource_type, null: false
      t.integer :resource_id, null: false
      t.integer :track_id, null: false
    end
    add_index :datapool_track_resources, [:resource_type, :resource_id, :track_id], unique: true, name: "datapool_track_resources_unique_relation_index"
    add_index :datapool_track_resources, :track_id
  end
end
