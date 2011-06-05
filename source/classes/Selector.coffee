generateSelector = (parsed) -> 
  a = ""
  for exp in parsed.expressions
    a += if a isnt "" then "," else ""
    for e in exp
      a += e.combinator
      if e.id
        a += "##{e.id}"
      if e.tag isnt "*"
        a += e.tag
      else
        if e.classList?
          a += "."+e.classList.join "."
        else if e.id is undefined
          a += e.tag
      if e.pseudos
        for p in e.pseudos
          a += ":"+p.key
          if p.value isnt null
            a += "(#{p.value})"
  a.trim()
exports.Selector = class Selector
  constructor: (name, indent) ->
    @name = name
    @indent = indent
    @extends = []
    @props = []
  toString: ->
    try
      #x = (if @extends.length > 0 then ", " else "" ) + @extends.join ', '
      m = ""
      if @indent == 0
        m = "\n"
      if @indent > 0
        for [0..@indent-1]
          m += " "
      m +=  generateSelector @parsed
      p = @to_p()
      if p is "{ }\n"
        return ""
      m += " "+p
    catch e    
      console.log e
  to_p: ->
    m = "{\n" 
    indent = ""
    for [0..@indent+1]
      indent += " "
    Object.each @props, (v,k) ->
      if v.block?
        Object.each v.block.props, (v1,k1) ->
          m += indent+v1.toString()
      else
        m += indent+v.toString()
    m = m.trim()
    m += " }\n"
