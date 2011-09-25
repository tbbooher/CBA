module VotingHelpers

=begin
  def get_tally(votes)
    # this will count up the :ayes, :nays, and :abstains given a list of votes
    # called by build tally
    ayes = votes.count { |val| val == :aye }
    nays = votes.count { |val| val == :nay }
    abstains = votes.count { |val| val == :abstain }
    presents = votes.count { |val| val == :present }
    {:ayes => ayes, :nays => nays, :abstains => abstains, :presents => presents}
  end
=end

  def process_votes(votes)
    # takes a list of votes (of one type) and will add up all the nays, abstains, ayes
    v = votes.group_by { |v| v.value }
    aye_count = (v[:aye] ? v[:aye].count : 0)
    nay_count = (v[:nay] ? v[:nay].count : 0)
    present_count = (v[:present] ? v[:present].count : 0)
    abstain_count = (v[:abstain] ? v[:abstain].count : 0)
    {:ayes => aye_count, :nays => nay_count, :abstains => abstain_count, :presents => present_count}
  end

end