exports.Unit = class Unit
  constructor: (unit) ->
    m = unit.match /^[-\d]?(\d{1,10})(\S*)$/
    @number = Number.from unit
    @type = m[2]
  toString: ->
    @number + @type
    
Unit.from = (unit) -> 
  new Unit(unit)
