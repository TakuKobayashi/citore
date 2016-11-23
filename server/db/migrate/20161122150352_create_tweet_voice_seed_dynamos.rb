class CreateTweetVoiceSeedDynamos < ActiveRecord::Migration[5.0]
  def up
    return if TweetVoiceSeedDynamo.table_exists?
    migration = Aws::Record::TableMigration.new(TweetVoiceSeedDynamo)
    migration.create!(
      provisioned_throughput: {
        read_capacity_units: 5,
        write_capacity_units: 5
      }
    )
    migration.wait_until_available
  end

  def down
    migration = Aws::Record::TableMigration.new(TweetVoiceSeedDynamo)
    migration.delete!
  end
end
