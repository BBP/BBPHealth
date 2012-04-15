$ ->
  success= (position) ->
    window.position = position
    # Set lat/lng hidden field
    if position && position.coords
      $('#medication_lat').val(position.coords.latitude)  
      $('#medication_lng').val(position.coords.longitude)

  error= ->

  navigator.geolocation.getCurrentPosition(success, error) if (navigator.geolocation && $('#medication_lat').length) 
    
