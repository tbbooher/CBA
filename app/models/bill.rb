#require 'ny-times-congress'
#include NYTimes::Congress
#Base.api_key = 'ecabdba6f1f7d9c9422c717af77d0e23:11:63892295'

class Bill
  include Mongoid::Document
  # initial fields
  field :congress, :type => Integer
  field :bill_number, :type => Integer
  field :bill_type, :type => String
  #field :status, :type => String
  #field :title, :type => String
  #field :link, :type => String
  field :last_updated, :type => Date
  # update fields from GovTrackBill

  field :bill_state, :type => String #
  field :introduced_date, :type => Date #
  field :titles, :type => Array #
  #field :sponsor, :type => Integer #
  field :summary, :type => String #
  field :bill_actions, :type => Array #

  # things  i get  separt
  field :bill_html, :type => String

  #field :average_rating, :type => Float
  # things i calculate
  field :ident, :type => String
  field :cosponsors_count, :type => Integer
  field :govtrack_id, :type => String
  # add index
  field :govtrack_name, :type => String

  field :summary_word_count, :type => Integer
  field :text_word_count, :type => Integer

  field :text_updated_on, :type => Date
  field :hidden, :type => Boolean

  #embedded_in :sponsor, :class_name => "Legislator"
  belongs_to :sponsor, :class_name => "Legislator"
  has_and_belongs_to_many :cosponsors, :order => :state, :class_name => "Legislator"

  embeds_many :votes

  before_validation(:set_ids, :on => :create)
  #before_save :update_bill # TODO, we need to figure out when to update bills
  #after_save :update_legislator_counts

  # might need to remove
  def validate
    if errors.empty?
      begin
        GovKit::OpenCongress::Bill.find_by_idents(self.ident).first
        #Drumbone::Bill.find :bill_id => self.ident
      rescue
        errors.add("The requested bill", "does not exist")
      end
    end
  end

#  def to_param
#    "#{id}-#{drumbone_id}"
#  end

  # TODO -- need to fix
  def title
    short_title.blank? ? official_title : short_title
  end

  def tally
    the_tally = Hash.new
    self.votes.group_by { |v| v.group.type }.each do |votes_by_group|
      votes = votes_by_group.last.map { |v| v.value }
      ayes = votes.count { |val| val == :aye }
      nays = votes.count { |val| val == :nay }
      abstains = votes.count { |val| val == :abstain }
      the_tally[votes_by_group.first] = [votes_by_group.last.last.group.name, [ayes, nays, abstains]]
    end
    the_tally
  end

  def voted_on?(user)
    self.votes.map { |v| v.user }.include?(user)
  end

  # TODO should be helper, or include?
  def descriptive_tally
    names = ["For", "Against", "Abstain"]
    out = "<ul id=\"tally\">"
    self.tally.each do |votes_for_group|
      out += "<li class=\"box\">"
      out += "<b>#{votes_for_group.first.to_s}</b>"
      out += "<div class=\"group_name\">#{votes_for_group.last.first}</div>"
      out += "<ul id=\"the_votes\">"
      votes_for_group.last.last.each_with_index do |count, index|
        out += "<li>#{names[index]}: #{count}</li>"
      end
      out += "</ul>"
      out += "</li>"
    end
    out += "</ul>"
    out += "<div class=\"clear_both\"></div>"
    out
  end

  def self.update_from_directory
    Dir.glob("#{Rails.root}/data/bills/*.xml").each do |bill_path|
      bill_name = bill_path.match(/.*\/(.*).xml$/)[1]
      b = Bill.find_or_create_by(:govtrack_name => bill_name)
      b.update_bill
    end
  end

  def self.create_from_feed(session)
    #feed_url = "http://www.govtrack.us/congress/billsearch_api.xpd?q=&session=#{session}&sponsor=&cosponsor=&status=INTRODUCED%2CREFERRED"
    feed_url = "#{GOVTRACK_URL}congress/billsearch_api.xpd?q=&session=112&sponsor=400003&cosponsor=&status=INTRODUCED%2CREFERRED"
    feed = Feedzirra::Feed.fetch_raw(feed_url)
    results = Feedzirra::Parser::Govtrack.parse(feed).search_results
    results.each do |result|
      bill = self.new(
          :congress => result.congress,
          :bill_type => result.bill_type,
          :bill_number => result.bill_number,
          :status => result.status
      )
      bill.save if bill.valid? # is this the best way to do this?
    end
  end

  def full_number
    case bill_type
      when 'h' then
        'H.R.'
      when 'hr' then
        'H.Res.'
      when 'hj' then
        'H.J.Res.'
      when 'hc' then
        'H.C.Res.'
      when 's' then
        'S.'
      when 'sr' then
        'S.Res.'
      when 'sj' then
        'S.J.Res.'
      when 'sc' then
        'S.C.Res.'
    end + ' ' + bill_number.to_s
  end

  def set_ids
    self.ident = "#{self.congress}-#{self.bill_type}#{self.bill_number}"
    self.govtrack_id = "#{self.bill_type}#{self.congress}-#{self.bill_number}"
  end

  def update_legislator_counts
    unless self.sponsor.nil?
      self.sponsor.update_attribute(:sponsored_count, self.sponsor.sponsored.length)
    end
    cosponsors.each do |cosponsor|
      cosponsor.update_attribute(:cosponsored_count, cosponsor.cosponsored.length)
    end
    if self.hidden?
      self.sponsor = nil
      self.cosponsors = []
      self.bill_html = nil
    end
  end

  def update_bill
    file_data = File.new("#{Rails.root}/data/bills/#{self.govtrack_name}.xml", 'r')
    bill = Feedzirra::Parser::GovTrackBill.parse(file_data)
    # check for changes
    if bill && (self.introduced_date.nil? || (bill.introduced_date.to_date > self.introduced_date))
      # front-matter
      self.congress = bill.congress
      self.bill_type = bill.bill_type
      self.bill_number = bill.bill_number
      self.last_updated = bill.last_updated.to_date
      # get titles
      # get actions
      self.bill_state = bill.bill_state
      self.introduced_date = bill.introduced_date.to_date

      self.titles = get_titles(bill.titles)
      self.summary = bill.summary
      self.bill_actions = bill.bill_actions

      # sponsors
      save_sponsor(bill.sponsor_id)
      save_cosponsors(bill.cosponsor_ids)

      # bill text
      get_bill_text if self.bill_html.blank? || self.text_updated_on.blank? || self.text_updated_on < Date.parse(bill.last_action.acted_at)
      
      self.cosponsors_count = self.cosponsors.count
      self.text_word_count = self.bill_html.to_s.word_count
      self.summary_word_count = self.summary.to_s.word_count
      true
    else
      false
    end

  end

  def get_bill_text
      bill_object = HTTParty.get("#{GOVTRACK_URL}data/us/bills.text/#{self.congress.to_s}/#{self.bill_type}/#{self.bill_type + self.bill_number.to_s}.html")
      self.bill_html = bill_object.response.body
      self.text_updated_on = Date.today
      Rails.logger.info "Updated Bill Text for #{self.ident}"
  end

  def save_sponsor(id)
    sponsor = Legislator.where(:govtrack_id => id).first

    if sponsor
      self.sponsor = sponsor
    else
      raise "sponsor not in database!"
    end
    self.sponsor.save
  end

  def save_cosponsors(cosponsors)
    cosponsors.each do |cosponsor_id|
      cosponsor = Legislator.where(:govtrack_id => cosponsor_id).first
      if cosponsor
        self.cosponsors << cosponsor
      else
        raise "cosponsor not found"
      end
    end
    self.save
  end

  def get_cosponsors(cosponsors)
    # only run this if we have cosponsors (unless to enter)
    self.cosponsors = []
    co_sponsors.each do |cosponsor_id|
      url = "http://www.govtrack.us/congress/person_api.xpd?id=#{cosponsor_id}"
      cosponsor = Feedzirra::Parser::GovTrackPerson.parse(url)    
      self.cosponsors << Legislator.find_or_create_by(:bioguide_id => cosponsor.bioguide_id,
                                                      :title => cosponsor.title,
                                                      :first_name => cosponsor.first_name,
                                                      :last_name => cosponsor.last_name,
                                                      :district => cosponsor.district,
                                                      :state => cosponsor.state, #!!
                                                      :party => cosponsor.party, #!!
                                                      :youtube_id => cosponsor.youtube_id,
                                                      :user_approval => cosponsor.user_approval
                                                      )
    end

  end

  def get_titles(raw_titles)
    titles = Array.new
    raw_titles.each_slice(2) do |title|
      titles.push title
    end
    titles
  end

  def get_actions(raw_actions)
    actions = Array.new
    raw_actions.each_slice(2) do |action|
      actions.push action
    end
    actions
  end

  # TODO -- need to write ways to get titles and actions for views (but not what we store in the db)

  def update_bill_old
    unless self.hidden?
      #bill = GovKit::OpenCongress::Bill.find_by_idents(self.ident).first
      file_data = File.new("#{Rails.root}/data/bills/#{self.bill_type}#{self.bill_number}.xml", 'r')
      bill = Feedzirra::Parser::GovTrackBill.parse(file_data)
      #feed_url = "#{GOVTRACK_URL}http://www.govtrack.us/congress/person_api.xpd?id=#{300058}"
      #feed = Feedzirra::Feed.fetch_raw(feed_url)
      #bill = Feedzirra::Parser::Govtrack.parse(feed).search_results
      if bill
        #titles = Bill.get_titles(bill.bill_titles)
        #self.short_title = titles["short"]
        #self.official_title = titles["official"]
        #last_action = Bill.last_action(bill.most_recent_actions)
        #self.last_action_text = last_action.text
        #self.last_action_on = last_action.acted_at
        #self.summary = bill.plain_language_summary
        #self.state = bill.status

        # sponsor = Legislator.where(:bioguide_id => bioguide_id).first

        # if sponsor
        #   self.sponsor_id = sponsor.id
        # else
        #   self.sponsor = Legislator.new(
        #       :bioguide_id => bill.sponsor.bioguideid,
        #       :title => bill.sponsor.title,
        #       :first_name => bill.sponsor.firstname,
        #       :last_name => bill.sponsor.lastname,
        #       :nickname => bill.sponsor.nickname,
        #       :district => bill.sponsor.district,
        #       :state => bill.sponsor.state,
        #       :party => bill.sponsor.party,
        #       :youtube_id => bill.sponsor.youtube_id,
        #       :user_approval => bill.sponsor.user_approval
        #   )
        #   self.sponsor.save
        # end

        # if bill.co_sponsors
        #   self.cosponsors = []
        #   bill.co_sponsors.each do |cosponsor|
        #     self.cosponsors << Legislator.find_or_create_by(:bioguide_id => cosponsor.bioguideid,
        #                                                     :title => cosponsor.title,
        #                                                     :first_name => cosponsor.firstname,
        #                                                     :last_name => cosponsor.lastname,
        #                                                     :nickname => cosponsor.nickname,
        #                                                     :district => cosponsor.district,
        #                                                     :state => cosponsor.state,
        #                                                     :party => cosponsor.party,
        #                                                     :youtube_id => cosponsor.youtube_id,
        #                                                     :user_approval => cosponsor.user_approval
        #     )
        #   end
        # end

        if self.bill_html.blank? || self.text_updated_on.blank? || self.text_updated_on < Date.parse(bill.last_action.acted_at)
          bill_object = HTTParty.get("#{GOVTRACK_URL}data/us/bills.text/#{self.congress.to_s}/#{self.bill_type}/#{self.bill_type + self.bill_number.to_s}.html")
          self.bill_html = bill_object.response.body
          self.text_updated_on = Date.today
          Rails.logger.info "Updated Bill Text for #{self.ident}"
        end

        self.sponsor_name = self.sponsor.last_name
        self.cosponsors_count = self.cosponsors.count
        self.text_word_count = self.bill_html.to_s.word_count
        self.summary_word_count = self.summary.to_s.word_count
        true
      else
        false
      end
    end
  end

end
