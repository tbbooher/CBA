require 'test_helper'

class LegislatorTest < ActiveSupport::TestCase

  def setup
    @legislator = Factory.build(:legislator)
  end
  # Replace this with your real tests.
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
    assert_equal(Legislator.all.count,542)
  end
end
