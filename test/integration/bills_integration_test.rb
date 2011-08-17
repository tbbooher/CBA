require 'test_helper'

class BillsIntegrationTest < ActionDispatch::IntegrationTest

  def setup
    Bill.destroy_all
    @bill = Bill.find_or_create_by(
        :congress => 112,
        :bill_type => 's',
        :bill_number => 368,
        :title => 's368',
        :govtrack_name => 's368'
    )
    @bill.update_bill
  end

  test "The sponsor should be loaded correctly" do
    assert @bill.save
    assert_not_nil(@bill.sponsor)
    assert_equal("K000305", @bill.sponsor.bioguide_id)
  end

  test "The sponsors should be loaded correctly" do
    assert_not_nil(@bill.cosponsors)
  end

  test "A bill should have a ident after it is created" do
     assert_not_nil @bill.ident
     assert_equal(@bill.ident, "112-s368")
  end

  test "We can create some bills" do
    Bill.destroy_all
    Bill.update_from_directory do
      ['h26', 's782'].map { |b| "#{Rails.root}/data/bills/#{b}.xml" }
    end
    assert_operator Bill.all.count, :>=, 0
  end

end
