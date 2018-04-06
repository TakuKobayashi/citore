# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

set :output, "#{path}/log/cron.log"

every :day, at: '11:00' do
  runner "Homepage.import_routine!"
end

every :day, at: '10:00' do
  runner "Datapool::StoreProduct.update_data!"
end

every :day, at: '7:00' do
  runner "Datapool::StoreProduct.backup_to_s3"
end

every :day, at: '0:00' do
  runner "ResourceUtility.crawler_routine!"
end

=begin
every :day, at: "2:00 am" do
  rake "batch:db_dump_and_upload"
  command "/bin/echo `date`: Daily upload sql"
end

every 8.hours do
  rake "crawl:youtube"
  command "/bin/echo `date`: crawl youtube"
end

every :day, at: "8:00 am" do
  rake "batch:get_erokotoba"
  command "/bin/echo `date`: crawl youtube"
end
=end


# Example:
#
# set :output, "/path/to/my/cron_log.log"
#
# every 2.hours do
#   command "/usr/bin/some_great_command"
#   runner "MyModel.some_method"
#   rake "some:great:rake:task"
# end
#
# every 4.days do
#   runner "AnotherModel.prune_old_records"
# end

# Learn more: http://github.com/javan/whenever
