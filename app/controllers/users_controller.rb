class UsersController < ApplicationController

  load_and_authorize_resource :except => [:hide_notification, :show_notification, :notifications]
  respond_to :html, :js

  def index
    @user_count = User.count
    @users = User.all.reject { |u|
      !can? :read, u
    }.paginate(:page => params[:page],
               :per_page => CONSTANTS['paginate_users_per_page'])

    respond_to do |format|
      format.js
      format.html
    end
  end

  def show
  end

  def geocode
    @user = current_user
    @address_attempt = '@user.find_location_by_ip'
  end

  def district
    result = current_user.get_geodata(params)
    flash[:method] = result[:method]
    if !(result[:geo_data].all? {|r| r.to_s.match(/\A[+-]?\d+?(\.\d+)?\Z/)})
      flash[:notice] = "No addresses found, please refine your answer or try a different method."
      redirect_to users_geocode_path
    elsif false #result[:geo_data].address_count > 1
      @addresses = result[:geo_data].multiple_addresses # wrong !!
      @address = build_address(params)
      flash[:notice] = "more than one address found, please pick yours"
      flash[:multiple_addresses] = true
    else # they have one address, find the district
      # save the user
      current_user.save_coordinates(result[:geo_data].first, result[:geo_data].last)
      result = current_user.get_districts_and_members
      @district = "#{result.us_state}#{result.district}"
      current_user.save_district_and_members(@district, result)
      members = current_user.find_members
      @senior_senator = members[:senior_senator]
      @junior_senator = members[:junior_senator]
      @representative = members[:representative]
    end
  end

  def edit_role
    if is_current_user?(@user)
      redirect_to registrations_path, :alert => t(:you_can_not_change_your_own_role)
    end
  end

  def update_role
    @user.update_attributes!(params[:user])
    redirect_to registrations_path, :notice => t(:role_of_user_updated, :user => @user.name)
  end

  def crop_avatar
    if !@user.new_avatar?
      redirect_to @user, :notice => flash[:notice]
    elsif is_in_crop_mode?
      if @user.update_attributes(params[:user])
        render :show
      else
        redirect_to edit_user_path(@user), :error => @user.errors.map(&:to_s).join("<br />")
      end
    end
  end

  def destroy
    @user.delete
    redirect_to registrations_path,
                :notice => t(:user_deleted)
  end

  # GET /hide_notification/:created_at_as_id
  def show_notification
    if user_signed_in?
      ts = Time.at(params[:id].to_i)
      notification = current_user.user_notifications.where(:created_at => ts).first
      unless notification.nil?
        notification.hidden = false
        current_user.save!
        notice = t(:notification_successfully_shown)
        error = nil
      else
        notice = nil
        error = t(:notification_cannot_be_shown)
      end
      redirect_to :back, :notice => notice, :alert => error
    end
  end

  # GET /hide_notification/:created_at_as_id
  def hide_notification
    if user_signed_in?
      ts = Time.at(params[:id].to_i)
      notification = current_user.user_notifications.where(:created_at => ts).first
      unless notification.nil?
        notification.hidden = true
        current_user.save!
        notice = t(:notification_successfully_hidden)
        error = nil
      else
        notice = nil
        error = t(:notification_cannot_be_hidden)
      end
      redirect_to :back, :notice => notice, :alert => error
    end
  end

  def notifications
    @notifications = current_user.user_notifications.hidden
  end

  def details
    respond_to do |format|
      format.js
      format.html
    end
  end

  private
  def is_in_crop_mode?
    params[:user] &&
        params[:user][:crop_x] && params[:user][:crop_y] &&
        params[:user][:crop_w] && params[:user][:crop_h]
  end

end
