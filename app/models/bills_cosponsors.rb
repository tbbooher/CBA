class BillsCosponsors
  include Mongoid::Document
  field :bill_id, :type => Integer
  field :legislator_id, :type => Integer
  #TODO delete
end
