CONVERTABLE_UNITS = {"in" => 0,        "cm" => 1,    "pc" => 2,    "mm" => 3,   "pt" => 4}
CONVERSION_TABLE = [[ 1,                2.54,         6,            25.4,        72        ] # in
                    [ null,             1,            2.36220473,   10,          28.3464567] # cm
                    [ null,             null,         1,            4.23333333,  12        ] # pc
                    [ null,             null,         null,         1,           2.83464567] # mm
                    [ null,             null,         null,         null,        1         ]] # pt
exports.Unit = class Unit
  constructor: (unit) ->
    m = unit.match  /^((-|\.|\d)?\d*?\.?\d*)(\S*)$/
    @number = Number.from unit
    @type = m[3]
  toString: ->
    @number + @type
  convertTo: (to)->
    @number = @number
    @type = to
Unit.from = (unit) -> 
  new Unit(unit)
