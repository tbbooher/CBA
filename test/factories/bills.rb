# Read about factories at http://github.com/thoughtbot/factory_girl

#test/factories/bills.rb

Factory.define :bill, :class => OpenStruct do |f|
  f.ident "MyString"
  f.congress 1
  f.bill_type "MyString"
  f.bill_number 1
  f.short_title "Elba is bleak"
  f.official_title "MyString"
  f.summary "MyString"
  f.sponsor_id 1
  f.last_action_on "2011-05-29"
  f.last_action_text "MyString"
  f.enacted_on "2011-05-29"
  f.average_rating 1.5
  f.cosponsors_count 1
  f.govtrack_id "MyString"
  f.bill_html "MyString"
  f.summary_word_count 1
  f.text_word_count 1
  f.state "MyString"
  f.text_updated_on "2011-05-29"
  f.hidden false
  f.sponsor_name "MyString"
end