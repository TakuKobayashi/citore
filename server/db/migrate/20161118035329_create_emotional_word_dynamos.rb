class CreateEmotionalWordDynamos < ActiveRecord::Migration[5.0]
  def up
    return if EmotionalWordDynamo.table_exists?
    migration = Aws::Record::TableMigration.new(EmotionalWordDynamo)
    migration.create!(
      provisioned_throughput: {
        read_capacity_units: 5,
        write_capacity_units: 5
      }
    )
    migration.wait_until_available
  end

  def down
    migration = Aws::Record::TableMigration.new(EmotionalWordDynamo)
    migration.delete!
  end
end
