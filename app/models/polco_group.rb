class PolcoGroup
  include Mongoid::Document
  field :name, :type => String
  field :type, :type => Symbol, :default => :custom
  field :description, :type => String
  index :name
  index :type

  belongs_to :owner, :class_name => "User", :inverse_of => :custom_groups

  has_and_belongs_to_many :members, :class_name => "User", :inverse_of => :joined_groups
  has_and_belongs_to_many :followers, :class_name => "User", :inverse_of => :followed_groups

  # some validations
  validates_uniqueness_of :name, :scope => :type
  validates_inclusion_of :type, :in => [:custom, :state, :district, :common, :country], :message => 'Only valid groups are custom, state, district, common, country'

  scope :states, where(type: :state)
  scope :districts, where(type: :district)
  scope :customs, where(type: :custom)

  # time to create the ability to follow
  #has_many :followers, :class_name => "User", :inverse_of =>

  def followers_count
    self.follower_ids.count
  end
  
  def members_count
    self.member_ids.count
  end
end
