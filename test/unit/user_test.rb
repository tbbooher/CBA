require 'test_helper'

class UserTest < ActiveSupport::TestCase
  
  def setup
    User.delete_all
  end
  
  def cleanup
    User.delete_all
  end
  
  # Replace this with your real tests.
  test "A just built new user should not save" do
    user = User.new
    assert !user.save, "Saved new user without setting the object up for usage"
  end
  
  test "A user with email, name should not save without a password" do
    user = User.new(:email => 'tester@test.te', :name => 'Nockenfell')
    assert !user.save, "User saved without a password"
  end

  test "A user with email and password should not save without a name" do
    user = User.new(:email => 'tester@test.te', :password => 'secret', :password_confirmation => 'secret')
    assert !user.save, "User saved without a name"
  end
  
  test "A user should save with email, name, and password" do
    user = create_valid_user_with_id(1)
    assert user.save, "User not saved with email, name, and password"
  end
  
  test "A user should not save with wrong password-confirmation" do
    user = User.new(:email => 'tester@test.te', :password => 'secret', :password_confirmation => 'secred', :name => 'nockenfell')
    assert !user.save, "User saved with wrong password-confirmation"
  end
  
  test "A user should not save with invalid email-address" do
    user = User.new(:email => 'tester-not-valid.te', :password => 'secret', :password_confirmation => 'secret', :name => 'nockenfell')
    assert !user.save, "User saved with invalid email"
  end
  
  test "A username should not be used twice" do
    assert create_valid_user_with_id(1), "User should save once."
    assert !create_valid_user_with_id(1), "User should not be saved with a name already taken"
  end
  
  test "create_valid_user_with_roles_mask should create user records" do
    admin  = create_valid_user_with_roles_mask(:admin)
    assert User.count == 1, "User should be stored"
    assert admin.role?(:admin) == true, 'User should be admin'
  end
  
  test "First user should be set admin" do
    guest      = create_valid_user_with_roles_mask(:guest)
    assert guest.role?(:admin), "First User should be admin"
    new_guest      = create_valid_user_with_roles_mask(:moderator)
    assert new_guest.role?(:moderator), "Second User should not be admin"
  end
  
  test "User::with_role(:xxx) should list all users with :xxx or higher role_mask" do    
    admin      = create_valid_user_with_roles_mask(:admin)    
    guest      = create_valid_user_with_roles_mask(:guest)
    moderator  = create_valid_user_with_roles_mask(:moderator)
    assert_equal 3, User.count
    assert_equal 3, User.with_role(:guest).all.count
    assert_equal 2, User.with_role(:moderator).all.count
    assert_equal 1, User.with_role(:admin).all.count
  end

  test "should join a default unaffiliated group" do
    guest = create_valid_user_with_roles_mask(:guest)
    # use fabrications
    PolcoGroup.find_or_create_by(:name => "unaffiliated", :type => :custom)
    guest.add_default_group
    guest.save
    assert_equal 1, guest.joined_groups.size
    assert_equal "unaffiliated", guest.joined_groups.first.name
  end

  test "should be able to vote" do
    b = Fabricate(:bill)
    guest = create_valid_user_with_roles_mask(:guest)
    #guest = guest.create
    guest.vote_on(b, :aye)
    b.votes
  end

  test "should not be able to have their vote counted with a group they follow" do
    pending
    # b = a_bill
    # @user1 follows group a
    # @user1.vote_on(b, :aye)
    # check to make sure the count of ayes on b is zero for group "A"
    assert true
  end
  
end
