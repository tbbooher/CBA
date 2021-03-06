require 'mongoid/counter_cache'

class Vote
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::CounterCache

  field :value, :type => Symbol # can be :aye, :nay, :abstain, :present

  counter_cache :name => 'polco_group', :field => 'vote_count'

  belongs_to :user, index: true
  belongs_to :polco_group, index: true    # we might need to think this through -- never need to query PolcoGroup.votes, right?
  belongs_to :bill, index: true

  # what we don't want is a repeated vote, so that would be a bill_id, polco_group and user_id
  validates_uniqueness_of :user_id, :scope => [:polco_group_id, :bill_id]
  validates_presence_of :value, :user_id, :polco_group_id, :bill_id
  validates_inclusion_of :value, :in => [:aye, :nay, :abstain, :present], :message => 'You can only vote yes, no or abstain'

  #has_many :followers, :class_name => "User"

end
