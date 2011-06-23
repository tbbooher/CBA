require 'test_helper'

class BillTest < ActiveSupport::TestCase

  test "The sponsor should be loaded correctly" do
    bill = Bill.new(
        :congress => 112,
        :bill_type => 's',
        :bill_number => 368
    )
    bill.save
    assert_not_nil(bill.sponsor)
    assert_equal("K000305", bill.sponsor.bioguide_id)
  end

  test "The sponsors should be loaded correctly" do
    bill = Bill.new(
        :congress => 112,
        :bill_type => 's',
        :bill_number => 368
    )
    bill.save
    assert_not_nil(bill.cosponsors)
  end

  # Replace this with your real tests.
  test "A bill should have a ident after it is created" do
     bill = Bill.new(
                     :congress => 112,
                     :bill_type => 's',
                     :bill_number => 374
                     )
     bill.save
     assert_not_nil bill.ident
     assert_equal(bill.ident, "112-s374")
  end
end