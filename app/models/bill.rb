class Bill
  include ContentItem
  acts_as_content_item

  references_many :comments, :inverse_of => :commentable, :as => 'commentable'
  validates_associated :comments

  # needed for comments
  field :interpreter,                             :default => :markdown
  field :allow_comments,        :type => Boolean, :default => true
  field :allow_public_comments, :type => Boolean, :default => true

  # initial fields
  field :congress, :type => Integer
  field :bill_number, :type => Integer
  field :bill_type, :type => String

  field :last_updated, :type => Date
  # update fields from GovTrackBill

  field :bill_state, :type => String #
  field :introduced_date, :type => Date #
  field :titles, :type => Array #
  field :summary, :type => String #
  field :bill_actions, :type => Array #

  # things i get with an extra call
  field :bill_html, :type => String

  # things i calculate
  field :ident, :type => String
  field :cosponsors_count, :type => Integer
  field :govtrack_id, :type => String
  # add index
  field :govtrack_name, :type => String

  index :govtrack_name

  field :summary_word_count, :type => Integer
  field :text_word_count, :type => Integer

  field :text_updated_on, :type => Date
  field :hidden, :type => Boolean

  # roll call results
  field :roll_time, :type => DateTime
  index :roll_time
  field :ayes, :type => Integer
  field :nays, :type => Integer
  field :abstains, :type => Integer
  field :presents, :type => Integer

  scope :house_bills, where(title: /^h/)
  scope :senate_bills, where(title: /^s/)
  # Person.where(:age.exists => true)
  scope :house_roll_called_bills, where(:roll_time.exists => true) # .descending(:roll_time)

  belongs_to :sponsor, :class_name => "Legislator"
  has_and_belongs_to_many :cosponsors, :order => :state, :class_name => "Legislator"
  has_and_belongs_to_many :subjects

  validates_presence_of :govtrack_name

  has_many :votes
  embeds_many :member_votes

  def short_title
    # we show the first short title
    txt = nil
    if self.titles
      the_short_title = self.titles.select { |type, txt| type == 'short' }
      unless the_short_title.empty?
        txt = the_short_title.first.last
      end
    else
      Rails.logger.warn "no titles for #{self.ident}"
    end
    txt || self.title
  end

  def chamber
    self.title[0] == "h" ? :house : :senate
  end

  def long_title
    txt = nil
    if self.titles
      official_title = self.titles.select { |type, txt| type == 'official' }
    else
      raise "No official title for #{self.ident}"
    end
    txt = official_title.first.last unless official_title.empty?
    txt
  end

  def bill_title
    short_title || long_title || "no title available!"
  end

  def tiny_title
    self.title.capitalize
  end

  # ------------------- Public voting aggregation methods -------------------

  def tally # delete method calls to this
    build_tally(self.votes.all)
  end

  def get_overall_users_vote # RECENT
    #
    votes = self.votes.all.select do |v|
      v.polco_group.type == :common
    end
    process_votes(votes)
  end

  def get_votes_by_name_and_type(name, type) # RECENT
                                             # we need to protect against a group named by the state
    process_votes(self.votes.all.select { |v| (v.polco_group.name == name && v.polco_group.type == type) })
  end

  def get_vote_values(votes_collection)
    votes_collection.map { |v| v.value }
  end

  def voted_on?(user)
    if vote = user.votes.where(bill_id: self.id).first
       vote.value
    end
  end

  def users_vote(user)
    if vote = self.votes.all.select { |v| v.user = user }.first
      vote.value
    else
      "none"
    end
  end

  def descriptive_tally
    names = ["For", "Against", "Abstain"]
    out = "<ul id=\"tally\">"
    self.tally.each do |votes_for_group|
      out += "<li class=\"box\">"
      #out += "<b>#{votes_for_group.first.to_s}</b>"
      out += "<div class=\"group_name\">#{votes_for_group.first}</div>"
      out += "<ul id=\"the_votes\">"
      votes_for_group.last.each_with_index do |count, index|
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
    files = Dir.glob("#{Rails.root}/data/bills/*.xml")
    if block_given?
      # hr112-26, h112-1, h112-292
      files = yield(self)
    end

    files.each do |bill_path|
      bill_name = bill_path.match(/.*\/(.*).xml$/)[1]
      puts "processing #{bill_name}"
      b = Bill.find_or_create_by(:title => bill_name, :govtrack_name => bill_name)
      if block_given?
        b.update_bill do
          "block"
          #puts "block here"
          #bill.text_updated_on = Date.today
          #bill.bill_html = "The mock bill contents"
        end
      else
        b.update_bill
      end
      b.save!
    end
  end

  def self.full_type(bill_type)
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

  def get_latest_action
    last_action = self.bill_actions.sort_by { |dt, tit| dt }.last
    {:date => last_action.first, :description => last_action.last}
  end

  def update_bill
    # assumes self.govtrack_name
    if self.govtrack_name
      file_data = File.new("#{Rails.root}/data/bills/#{self.govtrack_name}.xml", 'r')
    else
      raise "The bill does not have the property govtrack_name."
    end
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

      # update subjects
      self.subjects = []
      bill.subjects.each do |subject|
        self.subjects.push(Subject.find_or_create_by(:name => subject))
      end
      #puts "the bill is valid? #{self.valid?}"

      # sponsors
      save_sponsor(bill.sponsor_id)
      save_cosponsors(bill.cosponsor_ids) unless bill.cosponsor_ids.empty?

      # Yield to a block that can perform arbitrary calls on this bill
      if block_given?
        yield(self)
      end

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
      # now add this bill to the sponsor
      self.save
      sponsor.bills.push(self)
      sponsor.save!
    else
      raise "sponsor not in database!"
    end
    self.save
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
    actions.sort_by { |d, a| d }.reverse
  end

  def Bill.update_rolls
    files = Dir.glob("#{Rails.root}/data/rolls/*.xml").sort_by{|f| f.match(/\/.+\-(\d+)\./)[1].to_i}
    # Yield to a block that can perform arbitrary calls on this bill
    # for testing
    if block_given?
      files = yield(self)
    end
    # let's see if the file contains bill data
    # TODO - (we need to modify this to only read in the new rolls)
    bill_list = Bill.all.map(&:govtrack_id)

    files.each do |bill_path|
      f = File.new(bill_path, 'r')
      puts "starting with #{f.path} . . ."
      # "h112-26"
      # at this point, we only read in bill roll calls
      # if 1. it is a bill roll, 2. if we are tracking that bill and 3. if the date of the roll is more recent than the last date of the roll recorded
      if bd = f.read.match(/\<bill session="(\d+)" type="(\w+)" number="(\d+)"/)
        bd = bd[1..3]
        if bill_list.include?("#{bd[1].first}#{bd[0]}-#{bd[2]}") # do we have this bill
          f.rewind
          feed = Feedzirra::Parser::RollCall.parse(f)
          date_for_update = Time.parse(feed.updated_time)
          if feed.bill_type # && !(feed.required == "QUORUM")
            govtrack_id = "#{feed.bill_type.first}#{feed.congress}-#{feed.bill_number}"
            if b = Bill.where(govtrack_id: govtrack_id).first # should not fail, already checked
              if b.roll_time.nil? || b.roll_time < date_for_update
                # clear all previous entries
                b.roll_time = date_for_update
                b.member_votes = []
                feed.roll_call.each do |v|
                  if l = Legislator.where(govtrack_id: v.member_id).first
                    b.member_votes << MemberVote.new(:value => Bill.get_value(v.member_vote), :legislator => l)
                  else
                    raise "legislator #{v.member_id} not found"
                  end
                end
                puts "success with #{bd[0]}-#{bd[1].first}#{bd[2]}"
                b.save!
              else
                puts "no need to run #{bd[0]}-#{bd[1].first}#{bd[2]}"
              end
            else
              puts "bill listed by #{govtrack_id} not found"
              Rails.logger.warn "bill listed by #{govtrack_id} not found"
            end
            puts "updated roll for #{feed.bill_type}#{feed.congress}-#{feed.bill_number}"
          else
            puts "#{f.path} is not a bill vote"
            Rails.logger.warn "#{f.path} is not a bill vote"
          end
        else
          puts "we don't have the bill #{bd[2].first}#{bd[1]}-#{bd[3]}"
        end
      else
        puts "#{f.path} not a bill roll"
        puts "for this ident: #{bd[0]}-#{bd[1]}#{bd[2]}" if bd
      end # check if bill roll
    end
  end

  def self.get_value(the_value)
    case the_value
      when "+"
        result = :aye
      when "-"
        result = :nay
      when "0"
        result = :abstain
      when "P"
        result = :present
      else
        raise "unknown value #{the_value} (expected +, -, P or 0)"
        # if this is the case, we have to parse from <option key="P">Present</option>
    end
    result
  end

  def find_member_vote(member)
    if self.member_votes
      out = self.member_votes.where(legislator_id: member.id).first.value
    else
      out = "no member votes to search"
    end
    out
  end

  def members_tally
    process_votes(self.member_votes)
  end

=begin
  def comment(user, text)
    the_comment = BillComment.new(:comment_text => text, :user => user)
    self.bill_comments << the_comment
    self.save
  end
=end

  # TODO -- need to write ways to get titles and actions for views (but not what we store in the db)

  private

  def process_votes(votes)
    # takes a list of votes (of one type) and will add up all the nays, abstains, ayes
    v = votes.group_by { |v| v.value }
    aye_count = (v[:aye] ? v[:aye].count : 0)
    nay_count = (v[:nay] ? v[:nay].count : 0)
    present_count = (v[:present] ? v[:present].count : 0)
    abstain_count = (v[:abstain] ? v[:abstain].count : 0)
    {:ayes => aye_count, :nays => nay_count, :abstains => abstain_count, :presents => present_count}
  end

  def get_tally(votes)
    ayes = votes.count { |val| val == :aye }
    nays = votes.count { |val| val == :nay }
    abstains = votes.count { |val| val == :abstain }
    presents = votes.count { |val| val == :present }
    {:ayes => ayes, :nays => nays, :abstains => abstains, :presents => presents}
  end

  def build_tally(votes_collection)
    the_tally = Hash.new
    votes_collection.group_by { |v| v.polco_group.name }.each do |votes_by_group|
      votes = get_vote_values(votes_by_group.last)
      the_tally[votes_by_group.last.last.polco_group.name] = get_tally(votes)
    end
    the_tally
  end

    # added by nate
  def self.bill_search(search)
    puts search
    if search
      # you have to have a class to perform where on (i think)
      self.where(short_title: /#{search}/i)
    else
      # does scoped work with mongoid
      scoped
    end
  end
  
end
