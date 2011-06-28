class Vote
  include Mongoid::Document
  field :value, :type => Symbol # can be :aye, :nay, :abstain
  #field :group_type, :type => Integer

  belongs_to :user
  belongs_to :polco_group

  embedded_in :bill

end
