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
end
