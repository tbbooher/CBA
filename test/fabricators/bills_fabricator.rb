Fabricator(:bill) do
  title {Faker::Company.name}
  bill_actions {[["2011-02-17", "Message on Senate action sent to the House."], ["2011-02-16", "Received in the Senate."], ["2011-02-15T14:12:00-05:00", "Motion to reconsider laid on the table Agreed to without objection."], ["2011-02-15T14:06:00-05:00", "Considered as unfinished business."], ["2011-02-15T13:30:00-05:00", "POSTPONED PROCEEDINGS - The Chair put the question on the adoption of the concurrent resolution, and by voice vote, the Chair announced the noes had prevailed. Mr. Woodall objected to the vote on the grounds that a quorum was not present. Further proceedings on the motion were postponed. The point of no quorum was withdrawn."], ["2011-02-15T13:28:00-05:00", "Considered as privileged matter."]]}
  bill_html "<body>\n  <p>H.Con.Res.17</p>\n  <p>Agreed to February 17, 2011</p>\n \ <p><em><center><p>One Hundred Twelfth Congress</p></center></em></p>\n  <p><em><center><p>of the</p></center></em></p>\n  <p><em><center><p>United States of America</p></center></em></p>\n"
  bill_number 17
  bill_state "PASSED:CONCURRENTRES"
  bill_type "hc"
  congress 112
  comments {[]}
  cosponsors {[Fabricate(:rep), Fabricate(:rep, :first_name => Faker::Name.first_name)]}
  cosponsors_count 2
  created_at Date.parse('2011-06-27 11:08:31.000000000Z')
  govtrack_id 'hc112-17'
  govtrack_name 'hc17'
  ident '112-hc17'
  introduced_date Date.parse('2011-02-15 00:00:00.000000000Z')
  last_updated Date.parse('2011-03-06 00:00:00.000000000Z')
  sponsor {Fabricate(:rep)}
  summary "\n\t2/17/2011--Passed Senate without amendment. (This measure has not been amended since it was introduced. The summary of that version is repeated here.) Declares that when the House adjourns on the legislative day of Thursday,"
  summary_word_count 94
  text_updated_on Date.parse('2011-06-27 00:00:00.000000000Z')
  text_word_count 347
  titles {[["official", "Providing for an adjournment or recess of the two Houses."]]}
  updated_at Date.parse('2011-06-27 11:08:32.000000000Z')
end

