module PolcoGroupsHelper

  def show_people(people, name)
    unless people.count == 0
      o = content_tag :h2, name
      o << (content_tag :div, {:class => 'people_container'} do
        content_tag :ul, {:id => 'people'} do
          people.each do |person|
            concat(content_tag(:li, link_to(person.name, person)))
          end # people
        end #ul
      end )
      o.html_safe
    end # check
  end # show people

end
