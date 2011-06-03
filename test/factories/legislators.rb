# Read about factories at http://github.com/thoughtbot/factory_girl

Factory.define :legislator do |f|
  f.first_name "MyString"
  f.last_name "MyString"
  f.govtrack_id 1
  f.bioguide_id "MyString"
  f.title "MyString"
  f.nickname "MyString"
  f.name_suffix "MyString"
  f.district 1
  f.state "MyString"
  f.party "MyString"
  f.sponsored_count 1
  f.cosponsored_count 1
end