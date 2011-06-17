class Vote
  include Mongoid::Document
  field :bill_id_number, :type => Integer
  field :value, :type => Integer
  field :group_type, :type => Integer

  belongs_to :bill
  belongs_to :user

end
