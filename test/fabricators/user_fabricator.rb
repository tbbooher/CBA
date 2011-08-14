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
  #joined_groups { [Fabricate(:polco_group, {:name => 'Dan Cole', :type => :common}),
  #                Fabricate(:polco_group, {:name => 'CA', :type => :state}),
  #                Fabricate(:polco_group, {:name => 'CA46', :type => :district}),
  #                Fabricate(:polco_group, {:name => "Kirk\'s Kids", :type => :custom})] }
end