class BillComment
  include Mongoid::Document
  include Mongoid::Timestamps

  field :comment_date, :type => Date
  field :comment_text, :type => String

  # just add timestamps

  embedded_in :bill
  belongs_to :user

end
