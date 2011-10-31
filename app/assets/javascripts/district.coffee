$(document).ready ->
  if $("#users-district-display")
    $("#users-district-display").html('<img src="/assets/spinner.gif" alt="Loading ..." style="box-shadow: none">')
    #coords = $('#user-coords-token').html()
    #coords = "24.886436490787712, -70.2685546875"
    #state = $('#state-token').html()
    #district = $('#district-token').html()
    #json_data = $('#json-data').html()
    #if coords
    drawDistrictMap()

drawDistrictMap = () ->
  myLatLng = new google.maps.LatLng(d_data.centroid.lat,d_data.centroid.lon)
  myOptions =
    zoom: 5
    center: myLatLng
    mapTypeId: google.maps.MapTypeId.TERRAIN

  bermudaTriangle = undefined
  map = new google.maps.Map(document.getElementById("users-district-display"), myOptions)
  # we want this from json
  districtCoords = []
  for coord in d_data.coords
    gMapLatLon = new google.maps.LatLng(coord.lat, coord.lon)
    districtCoords.push(gMapLatLon)
  #triangleCoords = [ new google.maps.LatLng(25.774252, -80.190262), new google.maps.LatLng(18.466465, -66.118292), new google.maps.LatLng(32.321384, -64.75737), new google.maps.LatLng(25.774252, -80.190262) ]
  congressionalDistrict = new google.maps.Polygon(
    paths: districtCoords
    strokeColor: "#B88A00"
    strokeOpacity: 0.9
    strokeWeight: 2
    fillColor: "#F5B800"
    fillOpacity: 0.35
  )
  congressionalDistrict.setMap map
  southWest = new google.maps.LatLng(d_data.extents.southWest.lat,d_data.extents.southWest.lon)
  northEast = new google.maps.LatLng(d_data.extents.northEast.lat,d_data.extents.northEast.lon)
  bounds = new google.maps.LatLngBounds(southWest,northEast)
  map.fitBounds(bounds)