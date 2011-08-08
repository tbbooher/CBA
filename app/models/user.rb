# -*- encoding : utf-8 -*-

# This is a Device-User-Class extended with ROLES, Avatar-handling, and more
class User
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Paperclip
  include Geocoder::Model::Mongoid
  geocoded_by :coordinates
  cache

  devise :database_authenticatable, :registerable, :confirmable,
         :recoverable, :rememberable, :trackable, :validatable

  field :name, :type => String
  field :roles_mask, :type => Fixnum, :default => 0
  field :use_gravatar, :type => Boolean, :default => true
  field :invitation_id, :type => BSON::ObjectId
  field :zip_code, :type => String
  # for geocoding
  field :coordinates, :type => Array
  field :us_state  # TODO need type
  field :district  # TODO need type

  has_and_belongs_to_many :polco_groups
  has_many :legislators
  #has_many :votes

  def invitation
    @invitation ||= Invitation.criteria.for_ids(self.invitation_id).first
  end

  def invitation=(inv)
    @invitation = nil
    self.invitation_id = inv.id
  end

  references_many :authentications, :dependent => :delete
  references_many :postings, :dependent => :delete
  references_many :invitations, :dependent => :delete

  embeds_many :user_notifications

  validates_presence_of   :name
  validates_uniqueness_of :name, :case_sensitive => false
  validates               :email, :presence => true, :email => true
  validates_uniqueness_of :email, :case_sensitive => false


  attr_accessible :name, :email, :password, :password_confirmation, :roles_mask,
                  :remember_me, :authentication_token, :confirmation_token,
                  :avatar, :clear_avatar, :crop_x, :crop_y, :crop_w, :crop_h,
                  :time_zone, :language, :use_gravatar, :invitation_id

  attr_accessor :clear_avatar

  has_mongoid_attached_file :avatar,
                            :styles => {
                              :popup  => "800x600=",
                              :medium => "300x300>",
                              :thumb  => "100x100>",
                              :icon   => "64x64"
                            },
                            :processors => [:cropper]
  attr_accessor :crop_x, :crop_y, :crop_w, :crop_h
  after_update  :reprocess_avatar, :if => :cropping?

  # Notifications
  after_create   :async_notify_on_creation
  before_destroy :async_notify_on_cancellation
  before_update  :notify_if_confirmed

  # Authentications
  after_create :save_new_authentication
  after_create :first_user_hook

  # Roles - Do not change the order and do not remove roles if you
  # already have productive data! Thou it's safe to append new roles
  # at the end of the string. And it's safe to rename roles in place
  ROLES = [:guest, :confirmed_user, :author, :moderator, :maintainer, :admin, :registered]

  scope :with_role, lambda { |role| {:where => {:roles_mask.gte => ROLES.index(role)}} }

  def registered?
    (self.role == :registered || !self.zip_code.nil?)
  end

  def cropping?
    !crop_x.blank? && !crop_y.blank? && !crop_w.blank? && !crop_h.blank?
  end

  def avatar_geometry(style = :original)
    paperclip_geometry avatar, style
  end

  def new_avatar?
    avatar.updated_at && ((Time::now() - Time::at(self.avatar.updated_at)) < 1.minute)
  end

  def admin?
    User.all.any? ? (self == User.first || role?(:admin)) : true
  end

  def role=(role)
    self.roles_mask = ROLES.index(role)
    Rails.logger.warn("SET ROLES TO #{self.roles_mask} FOR #{self.inspect}")
  end

  # return user's role as symbol.
  def role
    ROLES[roles_mask].to_sym
  end

  # Ask if the user has at least a specific role.
  #   @user.role?('admin')
  def role?(role)
    self.roles_mask >= ROLES.index(role.to_sym)
  end

  # virtual attribute needed for the view but is false always.
  def clear_avatar
    false
  end

  # clear a previous uploaded avatar-image.
  def clear_avatar=(new_value)
    self.avatar = nil if new_value == '1'
  end

  # fetch attributes from the omniauth-record.
  def apply_omniauth(omniauth)
    self.email = omniauth['user_info']['email'] if email.blank?
    apply_trusted_services(omniauth) if self.new_record?
    authentications.build(:provider => omniauth['provider'], :uid => omniauth['uid'])
  end

  # remove the password and password-confirmation attribute if not needed.
  def update_with_password(params={})
    if params[:password].blank?
      params.delete(:password)
      params.delete(:password_confirmation) if params[:password_confirmation].blank?
    end
    super
  end

  # Remove an URL of the local avatar or the gravatar
  def avatar_url(mode)
    if self.use_gravatar
      "http://gravatar.com/avatar/#{gravatar_id}.png?cache=#{self.updated_at.strftime('%Y%m%d%H%M%S')}"
    else
      avatar.url(mode)
    end
  end

  # Link to the gravatar profile
  def gravatar_profile
    if self.use_gravatar
      "http://gravatar.com/#{gravatar_id}"
    end
  end

  def add_default_group
    self.polco_groups << PolcoGroup.where(:name => "unaffiliated").first
    self.save
  end

  def vote_on(bill, value)
    if my_groups = self.polco_groups
      my_groups.each do |g|
        bill.votes.create(:value => value, :user_id => self.id, :polco_group_id => g.id, :district => self.district, :us_state => self.us_state)
      end
    else
      raise "no polco_groups for this user" # #{self.full_name}"
    end
  end

  # district fun
  def get_district(coords)
    lat, lon = coords # .first, coords.last
    self.coordinates = [lat, lon]
    feed_url = "#{GOVTRACK_URL}perl/district-lookup.cgi?lat=#{lat}&long=#{lon}"
    feed = Feedzirra::Feed.fetch_raw(feed_url)
    govtrack_data = Feedzirra::Parser::GovTrackDistrict.parse(feed)
    if govtrack_data.districts.count > 1
      raise "too many"
    else
      result = govtrack_data.districts.first
      result.district = "#{result.us_state}#{"%02d" % result.district.to_i}"
    end
    [result]
  end

#  def get_and_save_district(lat,lon,save)
#    self.coordinates = [lat, lon]
#    feed_url = "#{GOVTRACK_URL}perl/district-lookup.cgi?lat=#{lat}&long=#{lon}"
#    feed = Feedzirra::Feed.fetch_raw(feed_url)
#    govtrack_data = Feedzirra::Parser::GovTrackDistrict.parse(feed)
#    if govtrack_data.districts.count > 1
#      raise "too many"
#    else
#      result = govtrack_data.districts.first
#      district = "#{result.us_state}#{"%02d" % result.district.to_i}"
#      save_district_and_members(district, result) if save
#      [district, result.us_state]
#    end
#  end

  def get_districts_by_zipcode(zipcode)
    feed_url = "#{GOVTRACK_URL}perl/district-lookup.cgi?zipcode=#{zipcode}"
    feed = Feedzirra::Feed.fetch_raw(feed_url)
    districts = Feedzirra::Parser::GovTrackDistrict.parse(feed).districts
    districts.each do |d|
      d.district = "#{d.us_state}#{"%02d" % d.district.to_i}"
    end
    districts
  end

  def add_district_data(junior_senator, senior_senator, representative, district, us_state)
    self.legislators.push(junior_senator)
    self.legislators.push(senior_senator)
    self.legislators.push(representative)
    self.district = district
    self.polco_groups.push(PolcoGroup.where(:name => us_state, :type => :state).first)
    self.polco_groups.push(PolcoGroup.where(:name => district, :type => :district).first)
    self.role = :registered # 7 = registered
    self.save!
  end

  def get_members(members)
    # look up legislators
    #legs = self.legislators
    legs = []
    members.each do |member|
      # need to clear previous members
      if leg = Legislator.where(:govtrack_id => member.govtrack_id).first
        legs << leg
      else
        raise "legislator #{member.govtrack_id} not found"
      end
    end
    senators = legs.select { |l| l.title == 'Sen.' }.sort_by { |u| u.start_date }
    members = Hash.new
    members[:senior_senator] = senators.first
    members[:junior_senator] = senators.last
    members[:representative] = (legs - senators).first
    members
  end

  def save_district_and_members(district, result)
    self.district = district
    self.legislators = []
    result.members.each do |member|
      # need to clear previous members
      if leg = Legislator.where(:govtrack_id => member.govtrack_id).first
        self.legislators << leg
      else
        raise "legislator #{member.govtrack_id} not found"
      end
    end
    self.save!
  end

  def get_geodata(params)
    case params[:commit]
      when "Yes" # the location is coming coming in from an ip lookup
        result = Geocoder.coordinates(params[:location])
        method = :ip_lookup
      when "Submit Address" # then, we have an address to code
        address = build_address(params)
        result = Geocoder.coordinates(address)
        method = :address
      when "Submit Zip Code" # we have a zip code to code
        result = get_district_by_zipcode(params[:zip_code])
        method = :zip_code
      when "Confirm address"
        result = params[:address]
        method = :confirmed_address
      else # they did a zip code lookup
        result = nil #Geocoder.coordinates(params[:full_zip])
        method = :none
    end
    {:geo_data => result, :method => method}
  end

  def get_ip(ip)
    Geocoder.coordinates(ip)
  end

  private
  def reprocess_avatar
    avatar.reprocess!
  end

  def gravatar_id
    Digest::MD5.hexdigest(self.email.downcase) if self.email
  end

  def apply_trusted_services(omniauth)

    # Merge user_info && extra.user_info
    user_info = omniauth['user_info']
    if omniauth['extra'] && omniauth['extra']['user_hash']
      user_info.merge!(omniauth['extra']['user_hash'])
    end

    # try name or nickname
    if self.name.blank?
      self.name   = user_info['name']   unless user_info['name'].blank?
      self.name ||= user_info['nickname'] unless user_info['nickname'].blank?
      self.name ||= (user_info['first_name']+" "+user_info['last_name']) unless \
        user_info['first_name'].blank? || user_info['last_name'].blank?
    end

    if self.email.blank?
      self.email = user_info['email'] unless user_info['email'].blank?
    end

    # Set a random password for omniauthenticated users
    self.password, self.password_confirmation = String::random_string(20)
    self.confirmed_at, self.confirmation_sent_at = Time.now

    # Build a new Authentication and remember until :after_create -> save_new_authentication
    @new_auth = authentications.build(:uid => omniauth['uid'], :provider => omniauth['provider'])
  end

  # Called :after_create
  def save_new_authentication
    @new_auth.save unless @new_auth.nil?
  end

  # Inform admin about sign ups and cancellations of accounts
  def async_notify_on_creation
    DelayedJob.enqueue('NewSignUpNotifier', Time.now, self.id)
  end

  # Inform admin about cancellations of accounts
  def async_notify_on_cancellation
    DelayedJob.enqueue('CancelAccountNotifier', Time.now, self.inspect)
  end

  # Inform admin if someone confirms an account
  def notify_if_confirmed
    if attribute_changed?('confirmed_at')
      DelayedJob.enqueue('AccountConfirmedNotifier', Time.now, self.id)
    end
  end

  # If created user is first user, confirm and make admin
  def first_user_hook
    if User.count < 2
      self.confirmed_at = Time.now
      self.role=:admin
      self.save!
    end
  end

end

