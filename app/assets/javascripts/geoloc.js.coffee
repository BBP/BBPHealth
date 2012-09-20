$ ->
  success= (position) ->
    window.position = position
    # Set lat/lng hidden field
    if position && position.coords
      $('#prescription_lat, #medication_lat').val(position.coords.latitude)
      $('#prescription_lng, #medication_lng').val(position.coords.longitude)

  error= (error)->
    console.log error.message

  navigator.geolocation.getCurrentPosition(success, error) if (navigator.geolocation && $('#prescription_lat, #medication_lat').length > 0)

