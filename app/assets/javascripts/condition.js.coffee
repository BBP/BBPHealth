class @Condition 
  constructor: (@el) -> 
    @el.on('change', '[data-condition] input', @update)
    @el.on('blur', '[data-condition] input[type="date"]', @update)

  update: =>
    $(@).trigger("changed")

  toString: ->
    conditions = []
    self       = @
    # Parse all element with a condition
    @el.find("[data-condition]").each (element) ->
      element = $(this)
      condition = element.data('condition')
      # In condition: field.in, get selected input
      if matched = condition.match(/(.*)\.(in|all|lte|gte|eq)$/)
        conditions = conditions.concat(self[matched[2]].apply(@, [element, matched]))

    # Set collection name
    conditions.push("collection=prescriptions")

    # Return a query string
    conditions.join("&")

   all: (element, matched) ->
    values = element.find('input:checked')
    conditions = []
    if values.length
      $.map values, (element) -> 
        conditions.push("#{matched[1]}[$#{matched[2]}][]=#{$(element).val()}")
    conditions

  # Alias for in condition
  in: Condition::all

  lte: (element, matched) ->
    input = $(element).find('input').first()
    value = input.val()

    conditions = []
    if value.length
      # Format date if it's a date with datepicker
      if input.hasClass('datepicker') && date = input.datepicker("getDate")
        value = moment(date).format('YYYY-MM-DD')

      conditions.push("#{matched[1]}[$#{matched[2]}]=#{value}")
    conditions

  # Alias for gte condition
  gte: Condition::lte

  eq: (element, matched) ->
    input = $(element).find('input').first()
    value = input.val()
    conditions = []
    if value.length
      conditions.push("#{matched[1]}=#{value}")
    conditions
