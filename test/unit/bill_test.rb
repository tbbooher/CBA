require 'test_helper'

class BillTest < ActiveSupport::TestCase

  def setup
    # replace this
    @the_bill = GovKit::OpenCongress::Bill.find_by_idents("112-s368").first
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

  #test "I want to be able to pull in full list of Bills." do
  #   Bill.destroy_all
  #   Bill.create_from_feed(112)
     #assert Bill.all.count >= 0
  #   assert_operator Bill.all.count, :>, 0
  #end

  test "A GovKit OpenCongress object should have titles" do
    #the_bill = Factory.create(:open_congress_bill)
    titles = Bill.get_titles(@the_bill.bill_titles)
    assert_not_nil(titles, "the_bill is nil")
    assert_equal("A bill to amend the Consolidated Farm and Rural Development Act to suspend a limitation on the period for which certain borrowers are eligible for guaranteed assistance.",titles["official"])
  end

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

  test "We should be able to pull out the most recent action " do
    last_action = Bill.last_action(@the_bill.most_recent_actions)
    assert_equal("Read twice and referred to the Committee on Agriculture, Nutrition, and Forestry.", last_action.text)
  end
end
