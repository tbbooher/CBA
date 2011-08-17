Fabricator(:user) do
  email { Faker::Internet.email }
  name { Faker::Name.name }
  roles_mask 1
  password "secret"
  password_confirmation "secret"
  #joined_groups { [Fabricate(:polco_group, :name => 'foreign', :type => :custom)] }
end

Fabricator(:admin, :from => :user) do
  roles_mask 5
end

Fabricator(:registered, :from => :user) do
  roles_mask 6
  coordinates { [38.79109100000001, -77.094729] }
  district 'CA46'
  us_state 'CA'
end