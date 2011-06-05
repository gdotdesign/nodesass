exports.Unit = class Unit
  constructor: (unit) ->
    m = unit.match  /^((-|\.|\d)?\d*?\.?\d*)(\S*)$/
    @number = Number.from unit
    @type = m[3]
  toString: ->
    @number + @type
    
Unit.from = (unit) -> 
  new Unit(unit)
