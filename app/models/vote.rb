class Vote
  include Mongoid::Document
  include Mongoid::Timestamps

  field :value, :type => Symbol # can be :aye, :nay, :abstain, :present
  #field :type, :type => Symbol  # TODO can delete?

  belongs_to :user
  belongs_to :polco_group    # we might need to think this through -- never need to query PolcoGroup.votes, right?
  belongs_to :bill

  # what we don't want is a repeated vote, so that would be a bill_id, polco_group and user_id
  # TODO -- ADD THIS VALIDATION LATER -- IT IS MESSING STUFF UP
  validates_uniqueness_of :user_id, :scope => [:polco_group_id, :bill_id]
  validates_presence_of :value, :user_id, :polco_group_id, :bill_id
  validates_inclusion_of :value, :in => [:aye, :nay, :abstain, :present], :message => 'You can only vote yes, no or abstain'

  #has_many :followers, :class_name => "User"

end
