module BillHelpers


  def update_rolls
    # go through each roll
    files = Dir.glob("#{Rails.root}/data/rolls/*.xml").sort_by{|f| f.match(/\/.+\-(\d+)\./)[1].to_i}
    # see if this is a new roll
      # if it is destroy all the previous votes and add these votes in
      # why in the heck would this happen
      #


  end


end