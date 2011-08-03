Fabricator(:page) do
   title                 'Page 1'
   body                  "Lorem ipsum"
   show_in_menu          true
   allow_comments        true
   allow_public_comments true
   allow_removing_component true
   is_draft              false
end

Fabricator(:page_with_default_template, :class_name => :page) do
  title                 'Page 1'
  body                  "Lorem ipsum"
  show_in_menu          true
  allow_comments        true
  allow_public_comments true
  allow_removing_component true
  is_draft              false
  page_template         PageTemplate.find_or_create_by(:name => 'default')
end


