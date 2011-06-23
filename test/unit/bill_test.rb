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
    user1 = Factory.build(:registered)
    user2 = Factory.build(:registered, :name => "another")
    user3 = Factory.build(:user, :name => "and_another")
    user4 = Factory.build(:user, :name => "and_yet_another")
    b = Factory.build(:bill)
    b.votes = []
    user1.vote_on(b, :aye)
    user2.vote_on(b, :nay)
    user3.vote_on(b, :aye)
    user4.vote_on(b, :abstain)
    tally = b.tally
    assert_equal [2,1,1], tally, "Expected 2 aye, 1 nay, and 1 abstain"
  end

  test "Descriptive tally should work" do
    user1 = Factory.build(:user)
    user2 = Factory.build(:user, :name => "another")
    user3 = Factory.build(:user, :name => "and_another")
    user4 = Factory.build(:user, :name => "and_yet_another")
    b = Factory.build(:bill)
    user1.vote_on(b, :aye)
    user2.vote_on(b, :nay)
    user3.vote_on(b, :aye)
    user4.vote_on(b, :abstain)
    tally = b.descriptive_tally
    assert_not_nil tally
  end

  test "to see if a user has already voted" do
    user = Factory.build(:user)
    b = Factory.build(:bill)
    user.vote_on(b,:aye)
    assert_true b.voted_on?(user)
  end

  test "to see if the right groups are added" do
    assert true
  end
end
