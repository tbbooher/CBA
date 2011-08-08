class PolcoGroup
  include Mongoid::Document
  field :name, :type => String
  field :type, :type => Symbol, :default => :custom
  index :name
  index :type

  # TODO would like to limit groups to :custom, :state, :district, :common

  has_and_belongs_to_many :users
  validates_uniqueness_of :name, :scope => :type

end
