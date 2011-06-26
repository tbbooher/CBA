#require 'ny-times-congress'
#include NYTimes::Congress
#Base.api_key = 'ecabdba6f1f7d9c9422c717af77d0e23:11:63892295'
#require 'httparty'

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

  #before_validation(:set_ids, :on => :create)
  #before_save :update_bill # TODO, we need to figure out when to update bills
  #after_save :update_legislator_counts

  # might need to remove
  # TODO remove . . .
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
  def short_title
    # we show the first short title
    txt = nil
    if the_short_title = self.titles.select{|type,txt| type == 'short'}
      txt = the_short_title.first.last
    end
    txt
  end

  def long_title
    txt = nil
    if official_title = self.titles.select{|type,txt| type == 'official'}
      txt = official_title.first.last
    end
    txt
  end

  def title
    short_title || long_title
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
    Dir.glob("#{Rails.root}/data/bills/small_set/*.xml").each do |bill_path|
      bill_name = bill_path.match(/.*\/(.*).xml$/)[1]
      b = Bill.find_or_create_by(:govtrack_name => bill_name)
      b.update_bill
      b.save!
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
      self.ident = "#{self.congress}-#{self.bill_type}#{self.bill_number}"
      self.govtrack_id = "#{self.bill_type}#{self.congress}-#{self.bill_number}"

      # get actions
      self.bill_state = bill.bill_state
      self.introduced_date = bill.introduced_date.to_date

      self.titles = get_titles(bill.titles)
      self.bill_actions = get_actions(bill.bill_actions)
      self.summary = bill.summary

      # sponsors
      save_sponsor(bill.sponsor_id)
      save_cosponsors(bill.cosponsor_ids) unless bill.cosponsor_ids.empty?

      # bill text
      get_bill_text if self.bill_html.blank? || self.text_updated_on.blank? || self.text_updated_on < Date.parse(self.bill_actions.first.first)
      
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
    actions.sort_by{|d,a| d}.reverse
  end

  # TODO -- need to write ways to get titles and actions for views (but not what we store in the db)

end
