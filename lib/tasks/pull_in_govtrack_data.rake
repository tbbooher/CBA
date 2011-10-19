

namespace :data do
    #require File.expand_path('config/environment.rb')
    desc "Update all bills, legislators and rolls from govtrack"
    task :get_govtrack_data => :environment do
      puts "updating legislators . . . "
      Legislator.update_legislators
      puts "updating bills from directory . . . "
      Bill.update_from_directory
      puts "updating rolls . . . "
      Bill.update_rolls
    end
end