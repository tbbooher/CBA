require 'test_helper'

class BillsControllerTest < ActionController::TestCase

  setup do
    Bill.destroy_all
    @bill = Fabricate(:bill)
    User.delete_all
    @user = Fabricate(:user)
    @request.env['devise.mapping'] = :user
    @user.confirm!
    sign_in @user
    SiteMenu.destroy_all
    SiteMenu.create(:name => Faker::Lorem.words(4), :target => Faker::Lorem.words(1), :info => Faker::Company.bs)
    SiteMenu.create(:name => Faker::Lorem.words(4), :target => Faker::Lorem.words(1), :info => Faker::Company.bs)
  end

#  before (:each) do
#
#
#
#    sign_in @user
#  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:bills)
  end

  test "should get new" do
    get :new
    false
    assert_response :success
  end

=begin

  test "should create bill" do
    assert_difference('Bill.count') do
      post :create, :bill => @bill.attributes
    end

    assert_redirected_to bill_path(assigns(:bill))
  end

  test "should show bill" do
    get :show, :id => @bill.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @bill.to_param
    assert_response :success
  end

  test "should update bill" do
    put :update, :id => @bill.to_param, :bill => @bill.attributes
    assert_redirected_to bill_path(assigns(:bill))
  end

  test "should destroy bill" do
    assert_difference('Bill.count', -1) do
      delete :destroy, :id => @bill.to_param
    end

    assert_redirected_to bills_path
  end
=end
end
