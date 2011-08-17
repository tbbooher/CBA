require 'test_helper'

class UserIntegrationTest < ActionDispatch::IntegrationTest

  def setup
    @guest = create_valid_user_with_roles_mask(:guest)
  end

  test "should be able to add congressional members when a district is identified" do
    #Fabricate(:junior_senator)
    coords =Geocoder.coordinates("39.954663,-75.194467")
    # need to stub this!
    d = guest.get_district(coords).first
    members = guest.get_members(d.members)
    senior_senator = members[:senior_senator]
    junior_senator = members[:junior_senator]
    representative = members[:representative]
    @guest.add_district_data(junior_senator,
                            senior_senator,
                            representative, d.district, d.us_state)
    assert_equal "Patrick", @guest.senators.first.first_name
    assert_equal "Robert", @guest.senators.last.first_name
    assert_equal "Chaka", @guest.representative.first_name
    assert_true @guest.save!
  end

  test "should be able to get location from ip address" do
    address = @guest.get_ip('74.96.49.135')
    assert_equal [38.8177, -77.1527], address, "address doesn't match'"
  end

  test "should be able to get their district from coordinates" do
    #guest = create_valid_user_with_roles_mask(:guest)
    coordinates = [39.954663, -75.194467]
    result = @guest.get_district(coordinates)
    assert_not_nil result, "problem with district result"
  end

end