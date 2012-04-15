$ ->
  success= (position) ->
    window.position = position
    # Set lat/lng hidden field
    $('#medication_lat').val(position.coords.latitude) if position && position.coords
    $('#medication_lng').val(position.coords.longitude) if position && position.coords

  error= ->

  navigator.geolocation.getCurrentPosition(success, error) if (navigator.geolocation && $('#medication_lat').length) 
    
