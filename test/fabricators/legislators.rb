Fabricator(:senior_senator, :class => :legislator) do
  bioguide_id 'B000944'
  first_name 'Sherrod'
  last_name 'Brown'
  middle_name
  religion 'Lutheran'
  pvs_id 27018
  os_id 'N00003535'
  metavid_id 'Sherrod_Brown'
  youtube_id 'SherrodBrownOhio'
  title 'Sen.'
  district
  state 'OH'
  party 'Democrat'
  full_name 'Sen. Sherrod Brown [D, OH]'
  govtrack_id 400050
end

Fabricator(:junior_senator, :class => :legislator) do
  bioguide_id 'P000449'
  first_name 'Robert'
  last_name 'Portman'
  middle_name 'J.'
  religion 'Methodist'
  pvs_id 27008
  os_id 'N00003682'
  metavid_id 'Robert_Portman'
  youtube_id 'SenRobPortman'
  title 'Sen.'
  district
  state 'OH'
  party 'Republican'
  full_name 'Sen. Robert Portman [R, OH]'
  govtrack_id 400325
end

Fabricator(:rep, :class => :legislator) do
  bioguide_id 'B000589'
  first_name "John"
  last_name 'Boehner'
  middle_name 'A.'
  religion 'Roman Catholic'
  pvs_id 27015
  os_id 'N00003675'
  metavid_id 'John_A._Boehner'
  youtube_id 'JohnBoehner'
  title 'Rep.'
  district 8
  state 'OH'
  party 'Republican'
  full_name 'Rep. John Boehner [R, OH-8]'
  govtrack_id 400036
end