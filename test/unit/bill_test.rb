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

  test "a bill should have a long and short title" do
    #the_bill = Factory.create(:open_congress_bill)
    titles = @the_bill.titles
    assert_not_nil(titles, "the_bill is nil")
    assert_equal("Making appropriations for the Department of Defense and the other departments and agencies of the Government for the fiscal year ending September 30, 2011, and for other purposes.", @the_bill.long_title)
    assert_equal("Full-Year Continuing Appropriations Act, 2011", @the_bill.short_title)
  end

  test "should be able to pull out the most recent action" do
    last_action = @the_bill.get_latest_action
    assert_equal("Returned to the Calendar. Calendar No. 14.", last_action[:description])
  end

  test "should be able to tally votes" do
    b = @the_bill
    b.votes = []
    @user1.vote_on(b, :aye)
    @user2.vote_on(b, :nay)
    @user3.vote_on(b, :aye)
    @user4.vote_on(b, :abstain)
    tally = b.tally
    tally_test = {:ayes => 2, :nays => 1, :abstains => 1}
    assert_equal tally_test, tally['VA'], "Expected 2 aye, 1 nay, and 1 abstain"
  end

  test "should be able to build a descriptive tally that prints the tally as html" do
    b = @the_bill
    @user1.vote_on(b, :aye)
    @user2.vote_on(b, :nay)
    @user3.vote_on(b, :aye)
    @user4.vote_on(b, :abstain)
    tally = b.descriptive_tally
    assert_not_nil tally
  end

  test "should verify that a user has already voted" do
    #user = Fabricate(:user, :name => "George Whitfield", :email => "awaken@gloucester.com")
    b = @the_bill
    @user1.vote_on(b, :aye)
    assert_true b.voted_on?(@user1)
  end

  test "should be able to add a sponsor to a bill" do
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

  test "should be able to read all bills from a directory and load them into the database" do
    Bill.destroy_all
    Bill.update_from_directory
    assert_operator Bill.all.to_a.count, :>=, 0
  end

  test "should show what the current user's vote is on a specific bill" do
    # why three votes here?
    b = Bill.new
    @user1.vote_on(b, :aye)
    assert_equal b.get_user_vote(@user1), :aye
  end

  test "should show the votes for a specific district that a user belongs to" do
    @user1.vote_on(@the_bill, :aye)
    # TODO USER 1 needs to be registered and given a district
    district = "OH08"
    district_tally = @the_bill.get_votes_for_district(district)
    assert_equal 1, district_tally  # {:ayes => 10, :nays => 20, :abstains => 2}
  end

  test "should block a user from voting twice on a bill" do
    assert true
  end

  test "should keep votes separate by group" do
    assert true
  end

  test "should be able to display users comments" do
    assert true
  end

  test "should be able to display it's rep votes" do
    assert true
  end

  test "should show the latest status for a bill" do
    assert true
  end

  test "should be able to show the house representative's vote if the bill is a hr" do
    assert true
  end

  test "should be able to show both senators votes if the bill is a sr" do
    assert true
  end

end
