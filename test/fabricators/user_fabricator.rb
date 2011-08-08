Fabricator(:user) do
   email      { Faker::Internet.email }
   name       { Faker::Name.name }
   roles_mask 1
   password   "secret"
   password_confirmation "secret"
   polco_groups {[Fabricate(:polco_group, :name => 'foreign', :type => :custom)]}
end

Fabricator(:admin, :from => :user) do
  roles_mask  5
end

Fabricator(:registered, :from => :user) do
   roles_mask 6
   coordinates {[38.79109100000001, -77.094729]}
   district 'CA46'
   us_state 'CA'
   polco_groups {[Fabricate(:polco_group, {:name => 'CL', :type => :state}),
              Fabricate(:polco_group, {:name => 'CA46', :type => :district}),
              Fabricate(:polco_group, {:name => "Kirk\'s Kids" , :type => :custom})]}
end

Fabricator(:user1, :from => :registered) do
   polco_groups {[Fabricate(:polco_group, {:name => 'CA', :type => :state}),
              Fabricate(:polco_group, {:name => 'CA46', :type => :district}),
              Fabricate(:polco_group, {:name => "Gang of 12" , :type => :custom})]}
end

Fabricator(:user2, :from => :registered) do
   polco_groups {[Fabricate(:polco_group, {:name => 'CA', :type => :state}),
              Fabricate(:polco_group, {:name => 'CA46', :type => :district}),
              Fabricate(:polco_group, {:name => "Ft. Sam Washington 1st Grade" , :type => :custom})]}
end

Fabricator(:user3, :from => :registered) do
   polco_groups {[Fabricate(:polco_group, {:name => 'VA', :type => :state}),
              Fabricate(:polco_group, {:name => 'VA05', :type => :district})]}
end

Fabricator(:user4, :from => :registered) do
   polco_groups {[Fabricate(:polco_group, {:name => 'VA', :type => :state}),
              Fabricate(:polco_group, {:name => 'VA03', :type => :district}),
              Fabricate(:polco_group, {:name => Faker::Company.name , :type => :custom})]}
end