require 'test_helper'

class PolcoGroupsControllerTest < ActionController::TestCase
  setup do
    PolcoGroup.destroy_all
    @polco_group = Fabricate(:polco_group)  # TODO fabricator
    User.delete_all
    @user = Fabricate(:user)
    @request.env['devise.mapping'] = :user
    @user.confirm!
    sign_in @user
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:polco_groups)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create group" do
    group_attributes = {:type => :custom, :name => Faker::Company.name}
    assert_difference('PolcoGroup.count') do
      post :create, :polco_group => group_attributes
    end

    assert_redirected_to polco_group_path(assigns(:polco_group))
  end

  test "should show group" do
    get :show, :id => @polco_group.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @polco_group.to_param
    assert_response :success
  end

  test "should update group" do
    put :update, :id => @polco_group.to_param, :group => @polco_group.attributes
    assert_redirected_to polco_group_path(assigns(:group))
  end

  test "should destroy group" do
    assert_difference('PolcoGroup.count', -1) do
      delete :destroy, :id => @polco_group.to_param
    end

    assert_redirected_to polco_groups_path
  end
end
