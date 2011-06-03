class Legislator
  include Mongoid::Document
  field :first_name, :type => String
  field :last_name, :type => String
  field :govtrack_id, :type => Integer
  field :bioguide_id, :type => String
  field :title, :type => String
  field :nickname, :type => String
  field :name_suffix, :type => String
  field :district, :type => Integer
  field :state, :type => String
  field :party, :type => String
  field :sponsored_count, :type => Integer
  field :cosponsored_count, :type => Integer
end
