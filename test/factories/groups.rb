# Read about factories at http://github.com/thoughtbot/factory_girl

Factory.define :group do |g|
  g.name "foreign"
  g.type :custom
  g.user_ids []
end