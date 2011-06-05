exports.Property = class Property
  constructor: (name, value)->
    @name = name
    @value = value
    @props = []
  toString: ->
    if @value isnt null
      m = @name + ": " + @value.toString().trim() + "; "
    else
      m = ""
    for p in @props
      p.name = @name + "-" + p.name
      m += p.toString()
    m
      

