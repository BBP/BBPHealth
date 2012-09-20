class @Condition
  constructor: (@el) ->
    @el.on('change', 'input[data-condition]', @update)
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

      return if element.attr("type") == "checkbox" and not element.is(":checked")
      if type = element.data("condition-type")
        condition = self[type].apply(self, [this, condition])

      conditions.push(condition) unless condition.length == 0

    # Return a query string
    conditions.join(" AND ")

  range: (element, condition) ->
    from = @valueOf($(element).find('.from'))
    to   = @valueOf($(element).find('.to'))

    condition.replace(/\?/, from).replace(/\?/, to)

  valueOf: (input, default_value = '*') ->
    value = input.val()
    if value.length > 0 and input.hasClass('datepicker') and (date = input.datepicker("getDate"))
      value  = moment(date).toDate().getTime() / 1000
      value += 86400 if input.hasClass('to')
    value = default_value if value.length == 0
    value

