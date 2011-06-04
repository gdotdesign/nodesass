exports.List = class List
  constructor: (a)->
    @s = a
  toString: ->
    @s
List.from = ->
  new List arguments[0]
