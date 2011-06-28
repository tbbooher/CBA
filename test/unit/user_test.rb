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
    user = User.new(:email => 'tester-at-test.te', :password => 'secret', :password_confirmation => 'secret', :name => 'nockenfell')
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

  test "User should join a default group" do
    guest = create_valid_user_with_roles_mask(:guest)
    PolcoGroup.find_or_create_by(:name => "unaffiliated", :type => :custom)
    guest.add_default_group
    guest.save
    assert_equal 1, guest.groups.count
    assert_equal "unaffiliated", guest.groups.first.name
  end

  test "User should be able to vote" do
    b = Factory.build(:bill)
    guest = create_valid_user_with_roles_mask(:guest)
    #guest = guest.create
    guest.vote_on(b, :aye)
    b.votes
  end

  test "User should be able to get district data" do
    guest = create_valid_user_with_roles_mask(:guest)
    guest.coordinates = [39.954663,-75.194467]
    guest.save!
    result = guest.get_districts_and_members
    assert_equal "2", result.district
    assert_equal "PA", result.us_state
    assert_equal 3, result.members.count
  end

  test "A user should be able to add members" do
    guest = create_valid_user_with_roles_mask(:guest)
    Fabricate(:junior_senator)
    guest.coordinates = [39.954663,-75.194467]
    guest.save!
    result = guest.get_districts_and_members
    district = "#{result.us_state}#{result.district}"
    guest.save_district_and_members(district, result)
    assert_equal 3, guest.legislators.count
  end

  test "Members and district should be saved for a user" do
    result = YAML::load(File.open("#{Rails.root}/test/fixtures/govtrack_result.yml"))
    guest = create_valid_user_with_roles_mask(:guest)
    @district = "#{result.us_state}#{result.district}"
    guest.save_district_and_members(@district, result)
    assert_equal 3, guest.legislators.to_a.count
    members = guest.get_three_members
    senior_senator = members[:senior_senator]
    junior_senator = members[:junior_senator]
    representative = members[:representative]
    assert_equal "Sherrod".to_s, senior_senator.first_name.to_s
    assert_equal "Robert".to_s, junior_senator.first_name.to_s
    assert_equal "John".to_s, representative.first_name.to_s
  end
  
end
