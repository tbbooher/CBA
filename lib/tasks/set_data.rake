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
    Bill.update_from_directory do
      ['h26', 's782'].map { |b| "#{Rails.root}/data/bills/#{b}.xml" }
    end
    # load rolls
    puts "updating rolls"
    Bill.update_rolls do
      ["#{Rails.root}/data/rolls/h2011-9.xml", "#{Rails.root}/data/rolls/s2011-91.xml"]
    end
  end
end