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

  def update_bill
    unless self.hidden?
      drumbone = Drumbone::Bill.find :bill_id => self.drumbone_id
      if drumbone
        self.short_title = drumbone.short_title
        self.official_title = drumbone.official_title
        self.last_action_text = drumbone.last_action.text
        self.last_action_on = drumbone.last_action.acted_at
        self.summary = drumbone.summary
        self.state = drumbone.state

        sponsor = Legislator.find_by_bioguide_id(drumbone.sponsor.bioguide_id)
        if sponsor
          self.sponsor_id = sponsor.id
        else
          self.create_sponsor(
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
        end

        if drumbone.cosponsors
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
          logger.info "Updated Bill Text for #{self.drumbone_id}"
        end

        self.sponsor_name = self.sponsor.last_name
        self.cosponsors_count = self.cosponsors.count
        self.text_word_count = self.bill_html.to_s.word_count
        self.summary_word_count = self.summary.to_s.word_count
        self.blind_count = self.find_blind.count
        self.deafblind_count = self.find_deafblind.count
        self.visually_impaired_count = self.find_visually_impaired.count
        true
      else
        false
      end
    end
  end

end
