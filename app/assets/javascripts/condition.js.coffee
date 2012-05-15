class @Condition 

  constructor: (@el) -> 
    @el.on('change', '[data-condition] input', @update)

  update: =>
    $(@).trigger("changed")

  toString: ->
    conditions = []
    # Parse all element with a condition
    @el.find("[data-condition]").each ->
      condition  = $(this).data('condition')
      # In condition: field.in, get selected input
      if matched = condition.match(/(.*)\.(in|all)$/)
        values = $(this).find('input:checked')
        if values.length
          $.map values, (element) -> 
            conditions.push("#{matched[1]}[$#{matched[2]}][]=#{$(element).val()}")
    console.log 'ok'
    # Return a query string
    conditions.join("&")

