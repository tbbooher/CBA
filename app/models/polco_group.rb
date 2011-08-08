class PolcoGroup
  include Mongoid::Document
  field :name, :type => String
  field :type, :type => Symbol, :default => :custom

  # TODO would like to limit groups to :custom, :state, :district

  has_and_belongs_to_many :users

end
