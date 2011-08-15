module BillsHelper

  def determine_vote(user)
    if user.nil? || !user_signed_in?
      out = "If you #{ link_to "log in", user_session_path }, you gain the right to vote"
    elsif @bill.voted_on?(user) # they can't vote again
      out = "Thanks for voting."
    elsif !user.registered?
      out = "You are logged in, but you haven't registered your district. #{ link_to "Change that", users_geocode_path}."
    else # they are registered, logged in, and haven't voted yet
      out = display_vote_options
    end
    out
  end


  def display_vote_options
    o = "<p>"
    o += %q{<b>Your vote:</b>}
    o += %q{<ul>}
    o += "<li>#{link_to "Yes", vote_on_bill_path(@bill, "aye")}</li>"
    o += "<li>#{link_to "No", vote_on_bill_path(@bill, "nay")}</li>"
    o += "<li>#{link_to "Abstain", vote_on_bill_path(@bill, "abstain")}</li>"
    o += %q{</ul>}
    o += "</p>"
    o
  end

  def last_action(bill)
    action = bill.get_latest_action
    "on #{action[:date]}, #{action[:description]}"
  end

end
