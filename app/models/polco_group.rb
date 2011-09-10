class PolcoGroup
  include Mongoid::Document
  field :name, :type => String
  field :type, :type => Symbol, :default => :custom
  field :description, :type => String
  index :name
  index :type
  field :follower_count, :type => Integer, :default => 0
  field :member_count, :type => Integer, :default => 0
  index :follower_count
  index :member_count

  belongs_to :owner, :class_name => "User", :inverse_of => :custom_groups

  has_and_belongs_to_many :members, :class_name => "User", :inverse_of => :joined_groups
  has_and_belongs_to_many :followers, :class_name => "User", :inverse_of => :followed_groups

  #we want to increment member_count when a new member is added
  before_save :update_followers_and_members

  # some validations
  validates_uniqueness_of :name, :scope => :type
  validates_inclusion_of :type, :in => [:custom, :state, :district, :common, :country], :message => 'Only valid groups are custom, state, district, common, country'

  scope :states, where(type: :state)
  scope :districts, where(type: :district)
  scope :customs, where(type: :custom)

  # time to create the ability to follow

  def update_followers_and_members
    #self.reload
    self.follower_count = self.followers.size
    self.member_count = self.members.size
  end
  
  def the_rep
    if self.type == :district
      if (self.name ~= /-AL/)  >= 0
        Legislator.all.select{|l| l.district_name == self.name}.first
    else
       "Only districts can have a representative"
    end
  end
end
