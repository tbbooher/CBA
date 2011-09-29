# -*- encoding : utf-8 -*-

module UsersHelper # :nodoc:

  def links_to_groups(user_groups)
    groups = []
    user_groups.each do |g|
      groups << link_to(g.name, g)
    end
    groups.to_sentence.html_safe
  end
end
