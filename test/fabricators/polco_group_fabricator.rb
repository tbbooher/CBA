Fabricator(:polco_group) do
  name Faker::Company.bs
  #title Faker::Company.name
  type :custom
  member_ids []
  follower_ids []
  comments []
end