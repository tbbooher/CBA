require 'test_helper'

class LegislatorTest < ActiveSupport::TestCase

  def setup
    @legislator = Factory.build(:legislator)
  end

  test "The chamber should update correctly" do
    assert_not_nil @legislator
    #assert true
  end

  test "We should get their party name" do
    assert_equal("Democrat", @legislator.party_name)
  end

  test "We should be able to read their full state name" do
    assert_equal("Colorado", @legislator.state_name)
  end

  test "We should be able to get their chamber" do
    assert_equal("U.S. Senate", @legislator.chamber)
  end

  test "We should be able to update all legislators" do
    Legislator.destroy_all
    Legislator.update_legislators
    # should be at least the number of reps (435) + the number of senators
    assert_operator Legislator.all.count, :>=, 535
  end

  test "We should be able to get the most recent actions from a legislator" do
    legislator_result = YAML::load(File.open("#{Rails.root}/test/fixtures/govtrack_person.yml"))
    role = Legislator.find_most_recent_role(legislator_result)
    assert_equal Date.parse("2009-01-06"), role.startdate
  end


end
