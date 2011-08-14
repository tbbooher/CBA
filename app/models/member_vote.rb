class MemberVote
  include Mongoid::Document
  include Mongoid::Timestamps

  field :roll_date, :type => Date
  field :value, :type => Symbol

  belongs_to :legislator
  embedded_in :bill

  # TODO validate that value is required
  # TODO not sure we need roll date

end
