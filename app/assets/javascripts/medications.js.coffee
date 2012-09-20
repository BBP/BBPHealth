$ ->

  # Autocomplete the secondary effects in edit form
  $("#secondary_effects_field").tagsInput
    autocomplete_url:"/secondary_effects"
    width:'auto'
    height:'auto'
    defaultText: ""

  # Add current secondary effect before submit
  $("#submit_with_secondary_effect").click (event) ->
    e = jQuery.Event("keypress")
    e.which = 13
    $("#secondary_effects_field_tag").trigger(e)
    true

  # Search in the background for similiar exisiting medications
  $('form#new_medication #medication_name, form#new_medication #medication_generic_name').change ->
    $.ajax
      url: "/medications/search.json?q=" + $("form#new_medication #medication_name").val()
      success: (data) ->
        $.each data, (index, value) ->
          $('#search_result').append("<div>There is already a medication called " + value.name + " ("+  value.generic_name + "), you can visit it here: " + '<a href="/medications/' + value.name.toLowerCase() + '">' + value.name + "</a></div>" );
