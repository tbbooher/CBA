#require 'ny-times-congress'
#include NYTimes::Congress
#Base.api_key = 'ecabdba6f1f7d9c9422c717af77d0e23:11:63892295'

class Bill
  include Mongoid::Document
  field :drumbone_id, :type => String
  field :congress, :type => Integer
  field :bill_type, :type => String
  field :bill_number, :type => Integer
  field :the_short_title, :type => String
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
  has_and_belongs_to_many :cosponsors, :order => :state, :join_table => "bills_cosponsors", :class_name => "Legislator"

  before_validation(:set_ids, :on => :create)
  before_save :update_bill
  #after_save :update_legislator_counts

  def validate
    if errors.empty?
      begin
        Drumbone::Bill.find :bill_id => self.drumbone_id
      rescue
        errors.add("The requested bill", "does not exist")
      end
    end
  end

  def to_param
    "#{id}-#{drumbone_id}"
  end

  def title
    the_short_title.blank? ? official_title : the_short_title
  end

  def self.create_from_feed(session)
    feed_url = "http://www.govtrack.us/congress/billsearch_api.xpd?q=&session=#{session}&sponsor=&cosponsor=&status=INTRODUCED%2CREFERRED"
    feed = Feedzirra::Feed.fetch_raw(feed_url)
    results = Feedzirra::Parser::Govtrack.parse(feed).search_results
    results.each do |result|
      bill = self.new(
          :congress => result.congress,
          :bill_type => result.bill_type,
          :bill_number => result.bill_number
      )
      bill.save if bill.valid?
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
    drumbone_type = case bill_type
                      when "h" then
                        "hr"
                      when "hr" then
                        "hres"
                      when "hj" then
                        "hjres"
                      when "hc" then
                        "hcres"
                      when "s" then
                        "s"
                      when "sr" then
                        "sres"
                      when "sj" then
                        "sjres"
                      when "sc" then
                        "scres"
                      else
                        bill_type
                    end

    self.drumbone_id = "#{drumbone_type}#{bill_number}-#{congress}"
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

  def update_bill
    unless self.hidden?
      drumbone = Drumbone::Bill.find :bill_id => self.drumbone_id
      if drumbone
        self.the_short_title = drumbone.short_title
        self.official_title = drumbone.official_title
        self.last_action_text = drumbone.last_action.text
        self.last_action_on = drumbone.last_action.acted_at
        self.summary = drumbone.summary
        self.state = drumbone.state

        #sponsor = Legislator.find_by_bioguide_id(drumbone.sponsor.bioguide_id)
        if sponsor
          self.sponsor_id = sponsor.id
        else
          self.sponsor = Legislator.new(
              :bioguide_id => drumbone.sponsor.bioguide_id,
              :title => drumbone.sponsor.title,
              :first_name => drumbone.sponsor.first_name,
              :last_name => drumbone.sponsor.last_name,
              :name_suffix => drumbone.sponsor.name_suffix,
              :nickname => drumbone.sponsor.nickname,
              :district => drumbone.sponsor.district,
              :state => drumbone.sponsor.state,
              :party => drumbone.sponsor.party,
              :govtrack_id => drumbone.sponsor.govtrack_id
          )
          self.sponsor.save
        end

        if false #drumbone.cosponsors
          self.cosponsors = []
          drumbone.cosponsors.each do |cosponsor|
            self.cosponsors << Legislator.find_or_create_by_bioguide_id(
                cosponsor.bioguide_id,
                :title => cosponsor.title,
                :first_name => cosponsor.first_name,
                :last_name => cosponsor.last_name,
                :name_suffix => cosponsor.name_suffix,
                :nickname => cosponsor.nickname,
                :district => cosponsor.district,
                :state => cosponsor.state,
                :party => cosponsor.party,
                :govtrack_id => cosponsor.govtrack_id
            )
          end
        end

        if self.bill_html.blank? || self.text_updated_on.blank? || self.text_updated_on < Date.parse(drumbone.last_action.acted_at)
          bill_object = HTTParty.get("http://www.govtrack.us/data/us/bills.text/#{self.congress.to_s}/#{self.bill_type}/#{self.bill_type + self.bill_number.to_s}.html")
          self.bill_html = bill_object.response.body
          self.text_updated_on = Date.today
          Rails.logger.info "Updated Bill Text for #{self.drumbone_id}"
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
