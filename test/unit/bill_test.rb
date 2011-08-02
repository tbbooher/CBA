require 'test_helper'

class BillTest < ActiveSupport::TestCase

  def setup
    # replace this
    #@the_bill = GovKit::OpenCongress::Bill.find_by_idents("112-s368").first
    @the_bill = YAML::load(File.open("#{Rails.root}/test/unit/helpers/bill.yaml"))
  end

  test "A GovKit OpenCongress object should have titles" do
    #the_bill = Factory.create(:open_congress_bill)
    titles = Bill.get_titles(@the_bill.bill_titles)
    assert_not_nil(titles, "the_bill is nil")
    assert_equal("A bill to amend the Consolidated Farm and Rural Development Act to suspend a limitation on the period for which certain borrowers are eligible for guaranteed assistance.",titles["official"])
  end

  test "We should be able to pull out the most recent action " do
    last_action = Bill.last_action(@the_bill.most_recent_actions)
    assert_equal("Read twice and referred to the Committee on Agriculture, Nutrition, and Forestry.", last_action.text)
  end

  test "We should be able to tally votes" do
    # basically i want an array of the [:ayes, :nays, :abstains]
    user1 = Fabricate(:registered)
    user2 = Fabricate(:registered, :name => "another")
    user3 = Fabricate(:user, :name => "and_another")
    user4 = Fabricate(:user, :name => "and_yet_another")
    b = Fabricate(:bill)
    b.votes = []
    user1.vote_on(b, :aye)
    user2.vote_on(b, :nay)
    user3.vote_on(b, :aye)
    user4.vote_on(b, :abstain)
    tally = b.tally
    assert_equal [2,1,1], tally, "Expected 2 aye, 1 nay, and 1 abstain"
  end

  test "Descriptive tally should work" do
    user1 = Fabricate(:user)
    user2 = Fabricate(:user, :name => "another")
    user3 = Fabricate(:user, :name => "and_another")
    user4 = Fabricate(:user, :name => "and_yet_another")
    b = Fabricate(:bill)
    user1.vote_on(b, :aye)
    user2.vote_on(b, :nay)
    user3.vote_on(b, :aye)
    user4.vote_on(b, :abstain)
    tally = b.descriptive_tally
    assert_not_nil tally
  end

  test "to see if a user has already voted" do
    user = Fabricate(:user)
    b = Fabricate(:bill)
    user.vote_on(b,:aye)
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

  test "we can get the title" do
    Bill.destroy_all
    Bill.update_from_directory
    b = Bill.first
    assert_equal "Common Sense Economic Recovery Act of 2011", b.title
  end
end
