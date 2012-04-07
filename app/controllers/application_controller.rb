# -*- encoding : utf-8 -*-

# Define methods which should be called with every request to your application
# or which should be callable from anywhere of your controllers
#
# == Preloading
# CBA will load all pages to <code>@top_pages</code>
# marked with 'show_in_menu' and orders them by
# 'menu_order asc'. This pages will be displayed as a 'main-menu'
# (see views/home/menu/)

class ApplicationController < ActionController::Base
  protect_from_forgery

  # Use a layout-file defined in application.yml
  layout ENV['APPLICATION_CONFIG_layout'] ? ENV['APPLICATION_CONFIG_layout'].to_s.strip : 'application'

  # persistent language for this session/user
  before_filter  :set_language_from_cookie
  before_filter  :apply_invitation
  before_filter  :setup_search

  # == Display a flash if CanCan doesn't allow access
  rescue_from CanCan::AccessDenied do |exception|
    flash[:alert] = exception.message
    redirect_to root_url
  end

  # Load what every controller may expect to be there
  helper_method :top_pages
  helper_method :root_menu
  helper_method :draft_mode

  # Setup content for buttons on top of page
  #helper_method :pivotal_tracker_project
  #helper_method :github_project
  helper_method :twitter_name
  helper_method :twitter_link
  helper_method :current_role?


  def is_current_user? usr
    return current_user && (current_user == usr)
  end
  alias current_user? is_current_user?

private

  # Top Pages are shown in the top-menu
  def top_pages
    @top_pages ||= Page.where(:show_in_menu => true).asc(:menu_order)
  end

  def root_menu
    @root_menu ||= SiteMenu.roots.first
  end

  # Load link to pivotal tracker from config
  def pivotal_tracker_project
    @pivotal_tracker_project ||= ENV['APPLICATION_CONFIG_pivotal_tracker_project']
  end

  # Load link to github project from config
  def github_project
    @github_project          ||= ENV['APPLICATION_CONFIG_github_project']
  end

  # Load twitter nickname (button-label) from config
  def twitter_name
    @twitter_name            ||= ENV['APPLICATION_CONFIG_twitter_name']
  end

  # Load link to project's twitter-account from config
  def twitter_link
    @twitter_link            ||= ENV['APPLICATION_CONFIG_twitter_link']
  end

  # Set a permanent coockie to due user sticks to the same lang with each
  # request.
  def set_language_from_cookie
    if cookies && cookies[:lang]
      I18n.locale = cookies[:lang].to_sym
    end
  end

  # Set user.confirmed and invitation.accepted_at if session has :invitation_id
  def apply_invitation
    if user_signed_in? && session[:invitation_id]
      invitation = Invitation.find(session[:invitation_id])
      current_user.roles_mask = invitation.roles_mask
      current_user.invitation = invitation
      current_user.confirmed_at = invitation.accepted_at = Time.now
      invitation.save!
      current_user.save!
      session[:invitation_id] = nil
      flash[:notice] = t(:thank_you_for_accepting_your_invitation)
    end
  end

  # True if current_user's role is role or greater
  def current_role?(role)
    return false unless current_user
    User::ROLES.index(role.to_sym) <= current_user.roles_mask
  end
  
  def draft_mode
    return true if session[:draft_mode] && session[:draft_mode] == true
    false
  end
  
  def change_draft_mode(mode)
    if current_role?(:author)
      session[:draft_mode] = (mode && mode == "1")
    else
      session[:draft_mode] = false
    end
  end
  
  def setup_search
    params[:search] ||= {:search => ""}
    @search ||= Search.new(params[:search]||{:search => ""})
  end
    
  def present(object, klass=nil)
    klass ||= "#{object.class}Presenter".constantize
    klass.new(view_context, object)
  end

end
