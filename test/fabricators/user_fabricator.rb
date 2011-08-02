Fabricator(:user) do
   email      'user@domain.com'
   name       'user'
   roles_mask 1
   password   "secret"
   password_confirmation "secret"
   polco_groups {[Fabricate(:polco_group, :name => 'foreign', :type => :custom)]}
end

Fabricator(:admin, :class_name => :user) do
  email 'admin@yourdomain.com'
  name  'Administrator'
  roles_mask  5
  password   "secret"
  password_confirmation "secret"
end

Fabricator(:registered, :class_name => :user) do
   email      'user@domain.com'
   name       'Tim TheRegistered'
   roles_mask 2
   password   "the_secret"
   password_confirmation "the_secret"
   polco_groups {[Fabricate(:polco_group, {:name => 'AL', :type => :state}),
              Fabricate(:polco_group, {:name => 'AL01', :type => :district}),
              Fabricate(:polco_group, {:name => "Kirk\'s Kids" , :type => :custom})]}
end
