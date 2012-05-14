@Map = (->
  map = false
  mapController = false

  init= (points) ->
    # GOOGLE MAP
    # mapOptions = 
    #   zoom: 1,
    #   center: new google.maps.LatLng(25, 0),
    #   mapTypeId: google.maps.MapTypeId.ROADMAP
    # map = new google.maps.Map document.getElementById('map'), mapOptions

    # Create Leaflet Map object
    map = new L.Map('map', scrollWheelZoom: false)

    # Set leaflet to use OpenStreetMap tiles
    mapquestUrl    = 'http://{s}.mqcdn.com/tiles/1.0.0/osm/{z}/{x}/{y}.png'
    subDomains     = ['otile1','otile2','otile3','otile4']
    mapquestAttrib = 'Data, imagery and map information provided by <a href="http://open.mapquest.co.uk" target="_blank">MapQuest</a>,<a href="http://www.openstreetmap.org/" target="_blank">OpenStreetMap</a> and contributors.'

    tileLayer = new L.TileLayer(mapquestUrl, maxZoom: 18, attribution: mapquestAttrib, subdomains: subDomains)
    map.setView(new L.LatLng(25, 0), 1).addLayer(tileLayer)

    mapSystem = new com.maptimize.Leaflet(map)
    mapController = new com.maptimize.MapController(new com.maptimize.Leaflet(map), {key: "1", url: "/map/"})

    mapController.refresh();

    # mapController = new com.maptimize.MapController(mapSystem, {url: "/map", key: ""})
    # mapController.refresh()

    # markers = for point in points
    #   latLng = new google.maps.LatLng(point.location.latitude, point.location.longitude)
    #   new google.maps.Marker(position: latLng, map: map)
  
    #markerCluster = new MarkerClusterer(map, markers)

  init:init
)()