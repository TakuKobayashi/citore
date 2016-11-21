class CreateVoiceDynamos < ActiveRecord::Migration[5.0]
  def up
    return if VoiceDynamo.table_exists?
    migration = Aws::Record::TableMigration.new(VoiceDynamo)
    migration.create!(
      provisioned_throughput: {
        read_capacity_units: 5,
        write_capacity_units: 1
      }
    )
    migration.wait_until_available
  end

  def down
    migration = Aws::Record::TableMigration.new(VoiceDynamo)
    migration.delete!
  end
end
