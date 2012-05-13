$ ->
  success= (position) ->
    window.position = position
    # Set lat/lng hidden field
    if position && position.coords
      $('#prescription_lat').val(position.coords.latitude)  
      $('#prescription_lng').val(position.coords.longitude)

  error= ->

  navigator.geolocation.getCurrentPosition(success, error) if (navigator.geolocation && $('#prescription_lat').length) 
    
