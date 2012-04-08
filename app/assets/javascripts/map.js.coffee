@Map = (->
  map = false
  markerCluster = false
  mapOptions = 
    zoom: 1,
    center: new google.maps.LatLng(25, 0),
    mapTypeId: google.maps.MapTypeId.ROADMAP

  init= (points) ->
    map = new google.maps.Map document.getElementById('map'), mapOptions

    markers = for point in points
      latLng = new google.maps.LatLng(point.position[1], point.position[0])
      new google.maps.Marker(position: latLng)
  
    markerCluster = new MarkerClusterer(map, markers)

  init:init
)()