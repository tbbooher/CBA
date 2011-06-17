class Group
  include Mongoid::Document
  field :name, :type => String
  field :type, :type => Symbol, :default => :custom

  has_and_belongs_to_many :users

end
