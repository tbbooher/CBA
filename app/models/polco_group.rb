class PolcoGroup
  include Mongoid::Document
  field :name, :type => String
  field :type, :type => Symbol, :default => :custom
  index :name
  index :type

  # TODO would like to limit groups to :custom, :state, :district, :common, :country

  has_and_belongs_to_many :members, :class_name => "User", :inverse_of => :joined_groups
  has_and_belongs_to_many :followers, :class_name => "User", :inverse_of => :followed_groups

  # some validations
  validates_uniqueness_of :name, :scope => :type
  validates_inclusion_of :type, :in => [:custom, :state, :district, :common, :country], :message => 'Only valid groups are custom, state, district, common, country'

  # time to create the ability to follow
  #has_many :followers, :class_name => "User", :inverse_of =>

end
