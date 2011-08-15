module BillsHelper

  def determine_vote(user)
    if user.nil? || !user_signed_in?
      out = "If you #{ link_to "log in", user_session_path }, you gain the right to vote"
    elsif vote = @bill.voted_on?(user) # they can't vote again
      case vote
        when :aye
          out = "You voted for this bill."
        when :nay
          out = "You voted against this bill."
        else
          out = "You abstained from voting on this bill."
      end
    elsif !user.registered?
      out = "You are logged in, but you haven't registered your district. #{ link_to "Change that", users_geocode_path}."
    else # they are registered, logged in, and haven't voted yet
      out = display_vote_options
    end
    out.html_safe
  end

  def determine_rep_vote(rep_vote, district)
    #<%= rep_vote[:rep] + "," + .to_s %>
    case rep_vote[:vote]
      when :aye
        action = "voted for this bill"
      when :nay
        action = "voted against this bill"
      else
        action = "abstained from voting on this bill"
    end
    "Your representative for #{district}, #{rep_vote[:rep]}, #{action}.".html_safe
  end

  def determine_senators_votes(votes)
     "#{votes.first[:senator]} voted #{votes.first[:vote].to_s} and #{votes.last[:senator]} voted #{votes.last[:vote].to_s}."
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

  def format_votes(vote_hash)
    o = "<ul class=\"votes\">"
    o += "<li>For: #{vote_hash[:ayes]}</li>"
    o += "<li>Against: #{vote_hash[:nays]}</li>"
    o += "<li>Abstain:#{vote_hash[:abstains]}</li>"
    o += "</ul>"
    o.html_safe
  end

  def format_votes_inline(vote_hash)
    "#{vote_hash[:ayes]} were for, #{vote_hash[:nays]} were against, and #{vote_hash[:abstains]} abstained."
  end

end
