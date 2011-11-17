# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

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

every 1.day, :at => '1:00 am' do
  rake "data:get_govtrack_data"
  command "thor update_gov_track_data:update_from_directory"    # updates all bills from directory
  command "thor update_gov_track_data:update_rolls"             # update the rolls of all bills
end

every 1.day, :at => '2:00 am' do
  rake "db:mongoid:create_indexes"
end