exports.Property = class Property
  constructor: (name, value)->
    @name = name
    @value = value
  toString: ->
    @name + ": " + @value.toString() + ";\n"

