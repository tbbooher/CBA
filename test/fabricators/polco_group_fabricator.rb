# Read about factories at http://github.com/thoughtbot/factory_girl

Fabricator(:polco_group) do
  name Faker::Company.bs
  type :custom
  user_ids []
end