exports.Selector = class Selector
  constructor: (name, indent) ->
    @name = name
    @indent = indent
    @extends = []
    @mixins = []
    @props = []
  toString: ->
    l = 0
    Object.each @props, (item) ->
      l += 1 if typeof item isnt "function"
    return "" unless l > 0
    x = (if @extends.length > 0 then ", " else "" ) + @extends.join ', '
    m =  @name + x 
    p = @to_p()
    m += @to_p()
  to_p: ->
    m = "{\n" 
    for mixin in @mixins
      Object.merge @props, mixin.block.props
    for k,v of @props
      if typeof v isnt "function"
        indent = ""
        for [0..@indent]
          indent += " "
        m += indent+v.toString()
        #m += k + ": " + v + end()
    m += "}\n"
