Factory.define :user do |u|
   u.email      'user@domain.com'
   u.name       'user'
   u.roles_mask 1
   u.password   "secret"
   u.password_confirmation "secret"
   u.groups {[Factory.build(:group, {:name => 'foreign', :type => :custom})]}
end

Factory.define :admin, :class => User do |u|
  u.email 'admin@yourdomain.com'
  u.name  'Administrator'
  u.roles_mask  5
  u.password   "secret"
  u.password_confirmation "secret"
end

Factory.define :registered, :class => User do |u|
   u.email      'user@domain.com'
   u.name       'Tim TheRegistered'
   u.roles_mask 2
   u.password   "the_secret"
   u.password_confirmation "the_secret"
   u.groups {[Factory.build(:group, {:name => 'AL', :type => :state}),
              Factory.build(:group, {:name => 'AL01', :type => :district}),
              Factory.build(:group, {:name => "Kirk\'s Kids" , :type => :custom})]}
end
