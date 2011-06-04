exports.Mixin = class Mixin
  constructor: (name, args) ->
    @vars = []
    vars = args.split /,/
    for k in vars
      m = k.match /\$(.*):(.*)/
      @vars[m[1]] = m[2]
    @name = name
    @args = args
    @props = []
  to_b: (args) ->
    
  to_s: ->
    ""
  toString: -> ""
