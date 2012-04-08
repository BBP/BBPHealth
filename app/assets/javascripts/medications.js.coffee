$ ->

  # Autocomplete the secondary effects in edit form
  $("#medication_secondary_effects").tagsInput
    autocomplete_url:"/secondary_effects"
    width:'auto'
    height:'auto'
    defaultText: ""

  # Search in the background for similiar exisiting medications
  $('form#new_medication #medication_name, form#new_medication #medication_generic_name').change ->
    $.ajax
      url: "/medications/search.json?q=" + $("form#new_medication #medication_name").val()
      success: (data) -> 
        $.each data, (index, value) ->
          $('#search_result').append("<div>There is already a medication called " + value.name + " ("+  value.generic_name + "), you can visit it here: " + '<a href="/medications/' + value.name.toLowerCase() + '">' + value.name + "</a></div>" );  
