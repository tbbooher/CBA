require 'test_helper'

class BillTest < ActiveSupport::TestCase

  # Called before every test method runs. Can be used
  # to set up fixture information.
  def setup
    # Do nothing
  end

  # Called after every test method runs. Can be used to tear
  # down fixture information.

  def teardown
    # Do nothing
  end

  # Replace this with your real tests.
  test "I should be able change a bills title" do
    #bill = Bill.new
    #bill.
    #assert !bill.save, "Saved new user without setting the object up for usage"
  end

  test "I should not be able to save an empty bill" do
    bill = Bill.new
    assert bill.save!, false
  end

  # Fake test
  def test_fail

    # To change this template use File | Settings | File Templates.
    fail("Not implemented")
  end
end