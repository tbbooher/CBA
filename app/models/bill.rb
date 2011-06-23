#require 'ny-times-congress'
#include NYTimes::Congress
#Base.api_key = 'ecabdba6f1f7d9c9422c717af77d0e23:11:63892295'

class Bill
  include Mongoid::Document
  field :ident, :type => String
  field :congress, :type => Integer
  field :bill_type, :type => String
  field :bill_number, :type => Integer
  field :short_title, :type => String
  field :official_title, :type => String
  field :summary, :type => String
  field :sponsor_id, :type => Integer
  field :last_action_on, :type => Date
  field :last_action_text, :type => String
  field :enacted_on, :type => Date
  field :average_rating, :type => Float
  field :cosponsors_count, :type => Integer
  field :govtrack_id, :type => String
  field :bill_html, :type => String
  field :summary_word_count, :type => Integer
  field :text_word_count, :type => Integer
  field :state, :type => String
  field :text_updated_on, :type => Date
  field :hidden, :type => Boolean
  field :sponsor_name, :type => String

  #embedded_in :sponsor, :class_name => "Legislator"
  belongs_to :sponsor, :class_name => "Legislator"
  has_and_belongs_to_many :cosponsors, :order => :state, :class_name => "Legislator"

  embeds_many :votes

  before_validation(:set_ids, :on => :create)
  #before_save :update_bill # TODO, we need to figure out when to update bills
  #after_save :update_legislator_counts

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

  def self.create_from_feed(session)
    #feed_url = "http://www.govtrack.us/congress/billsearch_api.xpd?q=&session=#{session}&sponsor=&cosponsor=&status=INTRODUCED%2CREFERRED"
    feed_url = "http://www.govtrack.us/congress/billsearch_api.xpd?q=&session=112&sponsor=400003&cosponsor=&status=INTRODUCED%2CREFERREDa"
    feed = Feedzirra::Feed.fetch_raw(feed_url)
    results = Feedzirra::Parser::Govtrack.parse(feed).search_results
    results.each do |result|
      bill = self.new(
          :congress => result.congress,
          :bill_type => result.bill_type,
          :bill_number => result.bill_number
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
    # h (house), s (senate), hj (house joint resolution), sj (senate joint resolution), hc (house concurrent resolution) sc (senate concurrent resolution), hr (house resolution), sr (senate resolution) 
    # drumbone_type = case bill_type
    #                   when "h" then
    #                     "hr"
    #                   when "hr" then
    #                     "hres"
    #                   when "hj" then
    #                     "hjres"
    #                   when "hc" then
    #                     "hcres"
    #                   when "s" then
    #                     "s"
    #                   when "sr" then
    #                     "sres"
    #                   when "sj" then
    #                     "sjres"
    #                   when "sc" then
    #                     "scres"
    #                   else
    #                     bill_type
    #                 end

    self.ident = "#{self.congress}-#{self.bill_type}#{self.bill_number}"
    self.govtrack_id = "#{bill_type}#{congress}-#{bill_number}"
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

  def self.last_action(actions)
    action_out = Struct.new(:text, :acted_at)
    most_recent = DateTime.new(1976, 8, 12, 0, 0, 0)
    out = nil
    actions.each do |last_action|
      the_date = last_action["created_at"].to_datetime
      if the_date > most_recent
        most_recent = the_date
        out = action_out.new(last_action["text"], the_date)
      end
    end
    out
  end

  def update_bill
    unless self.hidden?
      bill = GovKit::OpenCongress::Bill.find_by_idents(self.ident).first
      if bill
        titles = Bill.get_titles(bill.bill_titles)
        self.short_title = titles["short"]
        self.official_title = titles["official"]
        last_action = Bill.last_action(bill.most_recent_actions)
        self.last_action_text = last_action.text
        self.last_action_on = last_action.acted_at
        self.summary = bill.plain_language_summary
        self.state = bill.status

        sponsor = Legislator.where(:bioguide_id => bill.sponsor.bioguideid).first

        if sponsor
          self.sponsor_id = sponsor.id
        else
          self.sponsor = Legislator.new(
              :bioguide_id => bill.sponsor.bioguideid,
              :title => bill.sponsor.title,
              :first_name => bill.sponsor.firstname,
              :last_name => bill.sponsor.lastname,
              :nickname => bill.sponsor.nickname,
              :district => bill.sponsor.district,
              :state => bill.sponsor.state,
              :party => bill.sponsor.party,
              :youtube_id => bill.sponsor.youtube_id,
              :user_approval => bill.sponsor.user_approval
          )
          self.sponsor.save
        end


        if bill.co_sponsors
          self.cosponsors = []
          bill.co_sponsors.each do |cosponsor|
            self.cosponsors << Legislator.find_or_create_by(:bioguide_id => cosponsor.bioguideid,
                                                            :title => cosponsor.title,
                                                            :first_name => cosponsor.firstname,
                                                            :last_name => cosponsor.lastname,
                                                            :nickname => cosponsor.nickname,
                                                            :district => cosponsor.district,
                                                            :state => cosponsor.state,
                                                            :party => cosponsor.party,
                                                            :youtube_id => cosponsor.youtube_id,
                                                            :user_approval => cosponsor.user_approval
            )
          end
        end

        if self.bill_html.blank? || self.text_updated_on.blank? || self.text_updated_on < Date.parse(bill.last_action.acted_at)
          bill_object = HTTParty.get("http://www.govtrack.us/data/us/bills.text/#{self.congress.to_s}/#{self.bill_type}/#{self.bill_type + self.bill_number.to_s}.html")
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

  def self.get_titles(govkit_bill_titles)
    the_titles = {}
    govkit_bill_titles.each do |title|
      the_titles.store(title["title_type"], title["title"])
    end
    the_titles
  end

end
