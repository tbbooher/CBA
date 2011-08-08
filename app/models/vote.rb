class Vote
  include Mongoid::Document
  field :value, :type => Symbol # can be :aye, :nay, :abstain
  field :type, :type => Symbol
  #field :district, :type => String # district name
  #field :us_state, :type => String # two-character state shortcut
  #field :group_type, :type => Integer

  belongs_to :user
  belongs_to :polco_group

  embedded_in :bill

end
