require 'test_helper'

class PolcoGroupTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  def setup
     PolcoGroup.destroy_all
     common_group = Fabricate(:polco_group, {:name => 'Dan Cole', :type => :common})
     @cali_group = Fabricate(:polco_group, {:name => 'CA', :type => :state})
     @ca46 = Fabricate(:polco_group, {:name => 'CA46', :type => :district})
     @user1 = Fabricate.build(:registered, {:joined_groups => [common_group,
                                                                  @cali_group,
                                                                  @ca46,
                                                                  Fabricate(:polco_group, {:name => "Gang of 12", :type => :custom})]})
  end

  test "should not allow an unapproved type" do
    g = PolcoGroup.new
    g.members << @user1
    g.name = "The Battle of Vienna (1683)"
    g.type = :starhemberg
    assert !g.valid?
    assert_equal "Only valid groups are custom, state, district, common, country", g.errors.messages[:type].first
  end

  test "should force a unique name" do
    g1 = PolcoGroup.new
    g1.members << @user1
    g1.type = :custom
    g1.name = "Grand Vizier Merzifonlu Kara Mustafa Pasha"
    g1.save
    assert g1.valid?
    g2 = PolcoGroup.new
    g2.members << @user1
    g2.type = :custom
    g2.name = "Grand Vizier Merzifonlu Kara Mustafa Pasha"
    assert !g2.valid?
    assert_equal "is already taken", g2.errors.messages[:name].first
  end

  test "should allow a user to follow a group" do
    g = PolcoGroup.new
    g.type = :custom
    g.name = 'Polco Founders'
    g.followers << @user1
    assert_equal 1, g.followers.size
  end

  test "should add a user as a follower when a user follows the group" do
    # remove all followers from the group
    @cali_group.followers = []
    # add @user to followed groups
    @user1.followed_groups << @cali_group
    # now check that it is there
    assert_equal 1, @user1.followed_groups.count
    id = @cali_group.id
    @c = PolcoGroup.find(id)
    puts "%%" + @c.name
    puts "\n!! followers count:#{@c.followers.count}"
    puts "\n!! first follower: #{@c.followers.first.name}"
    @c.reload
    assert_equal 1, @c.followers.count
  end

  test "should add a group to a users followed_groups when a user is added as a follower to a group" do
    @cali_group.followers = []
    @cali_group.followers << @user1
    @cali_group.reload
    assert_equal @cali_group, @user1.followed_groups.first
  end

  test "should have one more follower when I add a follower to a group" do
    puts "starting test"
    @cali_group.members.delete_all
    @cali_group.save
    @cali_group.reload
    @cali_group.save
    puts "member count: !#{@cali_group.member_count}!"
    assert_equal 0, @cali_group.member_count
    @cali_group.members << @user1
    puts "before"
    puts @cali_group.member_count
    @cali_group.reload
    puts "member count 2: !#{@cali_group.member_count}!"
    assert_equal 1, @cali_group.member_count
  end

  test "should be able to sort by most popular group" do
    pending
  end

end
