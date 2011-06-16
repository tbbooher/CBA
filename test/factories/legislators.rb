# Read about factories at http://github.com/thoughtbot/factory_girl

Factory.define :legislator do |f|
  f.first_name "Mark"
  f.last_name "Udall"
  f.youtube_id "SenatorMarkUdall"
  f.bioguide_id "U000038"
  f.title "Sen."
  f.nickname "Markey"
  f.district
  f.state "CO"
  f.party "Democrat"
  f.user_approval 2.71875
  f.sponsored_count 1
  f.cosponsored_count 1
end