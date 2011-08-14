class Legislator
  include Mongoid::Document
  include Mongoid::Timestamps
  field :first_name, :type => String
  field :last_name, :type => String
  field :middle_name, :type => String
  field :religion, :type => String
  field :pvs_id, :type => Integer
  field :os_id, :type => String
  field :metavid_id, :type => String
  field :bioguide_id, :type => String
  field :youtube_id, :type => String
  field :title, :type => String
  field :nickname, :type => String
  field :user_approval, :type => String
  field :district, :type => Integer
  field :state, :type => String  # TODO -- CHANGE TO US_STATE
  field :party, :type => String
  field :sponsored_count, :type => Integer
  field :cosponsored_count, :type => Integer
  field :full_name, :type => String
  field :govtrack_id, :type => Integer
  field :start_date, :type => Date

  has_many :bills, :inverse_of => :sponsor

  def first_or_nick
    nickname.blank? ? first_name : nickname
  end

  def chamber
    case title
      when "Rep." then
        "U.S. House of Representatives"
      when "Sen." then
        "U.S. Senate"
      else
        title
    end
  end

  def image_location
    "/images/bio_photos/#{self.govtrack_id}-200px.jpeg"
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
      when "D" then
        "Democrat"
      when "R" then
        "Republican"
      when "I" then
        "Independent"
      else
        party
    end
  end

  def self.update_legislators
    file_data = File.new("#{Rails.root}/data/people.xml", 'r')
    feed = Feedzirra::Parser::GovTrackPeople.parse(file_data).people
    feed.each do |person|
      role = Legislator.find_most_recent_role(person)
      if !role.startdate.nil? && role.startdate >= 10.years.ago.to_date
        leg = Legislator.find_or_create_by(:bioguide_id => person.bioguide_id,
                                           :first_name => person.first_name,
                                           :last_name => person.last_name,
                                           :middle_name => person.middle_name,
                                           :religion => person.religion,
                                           :pvs_id => person.pvs_id,
                                           :os_id => person.os_id,
                                           :metavid_id => person.metavid_id,
                                           :bioguide_id => person.bioguide_id,
                                           :youtube_id => person.youtube_id,
                                           :title => person.title,
                                           :district => person.district,
                                           :state => person.state,
                                           :party => role.party,
                                           :start_date => role.startdate,
                                           :full_name => person.full_name,
                                           :govtrack_id => person.govtrack_id
        )
        leg.save
      end
    end
    file_data.close
  end

  def district_name
    "#{self.state}#{"%02d" % self.district.to_i}"
  end

  def self.find_most_recent_role(person)
    #array = [person.role_startdate.map{|d| Date.parse(d)}, person.role_party]
    role = OpenStruct.new
    if person.role_startdate.empty?
      role.party = nil
      role.startdate = nil
    else
      array = person.role_startdate.map { |d| Date.parse(d) }.zip(person.role_party).sort_by { |d, p| d }.reverse.first
      role.party = array.last
      role.startdate = array.first
    end
    role
  end
end
