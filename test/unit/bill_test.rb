require 'test_helper'

class BillTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  test "A bill should have a drumbone ID after it is created" do
         bill = Bill.new(
          :congress => 112,
          :bill_type => 's',
          :bill_number => 374
         )
         bill.save
         assert_not_nil bill.drumbone_id
  end
end
