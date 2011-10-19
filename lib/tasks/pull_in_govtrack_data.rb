class PullInGovtrackData < Thor
  Legislator.update_legislators
  Bill.update_from_directory
  Bill.update_rolls
end