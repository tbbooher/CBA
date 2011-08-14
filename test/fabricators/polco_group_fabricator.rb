Fabricator(:polco_group) do
  name Faker::Company.bs
  type :custom
  member_ids []
  follower_ids []
end