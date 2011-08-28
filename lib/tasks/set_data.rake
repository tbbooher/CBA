namespace :data do
  desc "Generate standard root_menu"
  task :load_bill_data => :environment do
    # load members
    puts "destroying legislators"
    Legislator.destroy_all
    puts "updating legislators"
    Legislator.update_legislators
    # load Bills (just test load)
    puts "destroying bills"
    Bill.destroy_all
    puts "updating bills from directory"
    Bill.update_from_directory
    # load rolls
    puts "updating rolls"
    Bill.update_rolls
  end
end