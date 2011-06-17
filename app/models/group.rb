class Group
  include Mongoid::Document
  field :name, :type => String
  field :type, :type => Integer
end
