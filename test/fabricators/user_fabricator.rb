Fabricator(:user) do
   email      'another_user_here@domain.com'
   name       'anew user'
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
   email      'registered_user@domain.com'
   name       'Tim TheRegistered'
   roles_mask 2
   password   "the_secret"
   password_confirmation "the_secret"
   polco_groups {[Fabricate(:polco_group, {:name => 'AL', :type => :state}),
              Fabricate(:polco_group, {:name => 'AL01', :type => :district}),
              Fabricate(:polco_group, {:name => "Kirk\'s Kids" , :type => :custom})]}
end

Fabricator(:user1, :class_name => :user) do
   email      'user1@domain.com'
   name       'User1'
   roles_mask 2
   password   "the_big_secret"
   password_confirmation "the_big_secret"
   polco_groups {[Fabricate(:polco_group, {:name => 'AL', :type => :state}),
              Fabricate(:polco_group, {:name => 'AL01', :type => :district}),
              Fabricate(:polco_group, {:name => "Kirk\'s Kids" , :type => :custom})]}
end

Fabricator(:user2, :class_name => :user) do
   email      'user2@domain.com'
   name       'User2'
   roles_mask 2
   password   "the_big_secret"
   password_confirmation "the_big_secret"
   polco_groups {[Fabricate(:polco_group, {:name => 'AL', :type => :state}),
              Fabricate(:polco_group, {:name => 'FL01', :type => :district}),
              Fabricate(:polco_group, {:name => "Ft. Sam Washington 1st Grade" , :type => :custom})]}
end

Fabricator(:user3, :class_name => :user) do
   email      'user3@domain.com'
   name       'User3'
   roles_mask 2
   password   "the_secret_is_out"
   password_confirmation "the_secret_is_out"
   polco_groups {[Fabricate(:polco_group, {:name => 'AL', :type => :state}),
              Fabricate(:polco_group, {:name => 'AL01', :type => :district}),
              Fabricate(:polco_group, {:name => "Kirk\'s Kids" , :type => :custom})]}
end

Fabricator(:user4, :class_name => :user) do
   email      'user4@domain.com'
   name       'User4'
   roles_mask 2
   password   "the_secret_again"
   password_confirmation "the_secret_again"
   polco_groups {[Fabricate(:polco_group, {:name => 'OH', :type => :state}),
              Fabricate(:polco_group, {:name => 'OH01', :type => :district}),
              Fabricate(:polco_group, {:name => "Kirk\'s Kids" , :type => :custom})]}
end