class Legislator
  include Mongoid::Document
  field :first_name, :type => String
  field :last_name, :type => String
  field :bioguide_id, :type => Integer
  field :youtube_id, :type => String
  field :title, :type => String
  field :nickname, :type => String
  field :user_approval, :type => String
  field :district, :type => Integer
  field :state, :type => String
  field :party, :type => String
  field :sponsored_count, :type => Integer
  field :cosponsored_count, :type => Integer

  has_many :sponsored, :class_name => "Bill", :foreign_key => "sponsor_id", :conditions => { :bills => { :hidden => false } }

  #embeds_many :bills

  def first_or_nick
    nickname.blank? ? first_name : nickname
  end

  def chamber
    case title
    when "Rep" then "U.S. House of Representatives"
    when "Sen" then "U.S. Senate"
    else title
    end
  end

  def full_name
    "#{first_or_nick} #{last_name}"
  end

  def full_title
    "#{title} #{full_name} (#{party}-#{state})"
  end

  def state_name
    state.to_us_state
  end

  def party_name
    case party
    when "D" then "Democrat"
    when "R" then "Republican"
    when "I" then "Independent"
    else party
    end
  end
end
