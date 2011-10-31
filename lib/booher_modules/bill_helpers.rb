module BillHelpers


  def update_rolls
    # go through each roll
    files = Dir.glob("#{Rails.root}/data/rolls/*.xml").sort_by{|f| f.match(/\/.+\-(\d+)\./)[1].to_i}
    # see if this is a new roll
      # if it is destroy all the previous votes and add these votes in
      # why in the heck would this happen
      #
    files.each do |bill_path|
      f = File.new(bill_path, 'r')
      if we_need_to_look_at_it(f)
        # get feed
        feed = Feedzirra::Parser::RollCall.parse(f)
      end
    end

  end

  def we_need_to_look_at_it(file_handle)
    # does the bill exist? && have we already read this file?
    # return true
  end

end