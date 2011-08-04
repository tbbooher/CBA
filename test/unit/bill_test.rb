require 'test_helper'

class BillTest < ActiveSupport::TestCase

  def setup
    load_all_sponsors
    @the_bill = Bill.new(:govtrack_name => "h1")
    @user1 = Fabricate.build(:user1)
    @user2 = Fabricate.build(:user2)
    @user3 = Fabricate.build(:user3)
    @user4 = Fabricate.build(:user4)
    @the_bill.update_bill do |bill|
      bill.text_updated_on = Date.today
      bill.bill_html = "The mock bill contents"
    end
    @the_bill.save!
  end

  test "A GovKit OpenCongress object should have titles" do
    #the_bill = Factory.create(:open_congress_bill)
    titles = @the_bill.titles
    assert_not_nil(titles, "the_bill is nil")
    assert_equal("Making appropriations for the Department of Defense and the other departments and agencies of the Government for the fiscal year ending September 30, 2011, and for other purposes.", @the_bill.long_title)
  end

  test "We should be able to pull out the most recent action " do
    last_action = @the_bill.get_latest_action
    assert_equal("Returned to the Calendar. Calendar No. 14.", last_action[:description])
  end

  test "We should be able to tally votes" do
    b = @the_bill
    b.votes = []
    @user1.vote_on(b, :aye)
    @user2.vote_on(b, :nay)
    @user3.vote_on(b, :aye)
    @user4.vote_on(b, :abstain)
    tally = b.tally
    assert_equal [2, 1, 1], tally, "Expected 2 aye, 1 nay, and 1 abstain"
  end

  test "Descriptive tally should work" do
    b = @the_bill
    @user1.vote_on(b, :aye)
    @user2.vote_on(b, :nay)
    @user3.vote_on(b, :aye)
    @user4.vote_on(b, :abstain)
    tally = b.descriptive_tally
    assert_not_nil tally
  end

  test "to see if a user has already voted" do
    user = Fabricate(:user, :name => "George Whitfield", :email => "awaken@gloucester.com")
    b = @the_bill
    user.vote_on(b, :aye)
    assert_true b.voted_on?(user)
  end

  test "to ensure titles are parsed properly" do
    titles = YAML::load(File.open("#{Rails.root}/test/fixtures/titles.yml"))
    b = Bill.new
    t = b.get_titles(titles)
    assert_equal "short", t.first.first
    assert_equal "CLEAR Act of 2011", t.first.last
  end

  test "to ensure we can save a sponsor" do
    b = Bill.new
    b.save_sponsor(400032)
    assert_equal "Marsha Blackburn", b.sponsor.full_name
  end

  test "save cosponsors for bill" do
    b = Bill.new(
        :congress => 112,
        :bill_type => 's',
        :bill_number => 368
    )
    cosponsor_ids = ["412411", "400626", "400224", "412284", "400570", "400206", "400209", "400068", "400288", "412271", "412218", "400141", "412480", "412469", "400277", "400367", "412397", "412309", "400411", "412283", "412434", "400342", "400010", "400057", "400260", "412487", "412436", "400348", "412478", "400633", "400656", "400115"]
    b.save_cosponsors(cosponsor_ids)
    assert_equal 32, b.cosponsors.to_a.count
  end

  test "update from directory" do
    Bill.destroy_all
    Bill.update_from_directory
    assert_operator Bill.all.to_a.count, :>=, 0
  end

end
