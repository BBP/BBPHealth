class @Condition 

  constructor: (@el) -> 
    @el.on('change', '[data-condition] input', @update)

  update: =>
    $(@).trigger("changed")

  toString: ->
    conditions = []
    # Parse all element with a condition
    @el.find("[data-condition]").each ->
      element = $(this)
      # In condition: field.in, get selected input
      if matched = element.data('condition').match(/(.*)\.(in|all)$/)
        values = element.find('input:checked')
        if values.length
          $.map values, (element) -> 
            conditions.push("#{matched[1]}[$#{matched[2]}][]=#{$(element).val()}")

    # Return a query string
    conditions.join("&")

