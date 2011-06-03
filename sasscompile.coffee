fs = require 'fs'
sys = require 'sys'
require 'mootools'
coffee = require 'coffee-script'
require './lib/mootoolsColor'
sasscompile = exports

Grammar = require './source/grammar'

Compressed = false

class List
  constructor: ->
  
List.from = ->
  @

class Unit
  constructor: (unit) ->
    m = unit.match TypeGrammar.unit.regexp
    @number = Number.from unit
    @type = m[2]
  toString: ->
    @number + @type
Unit.from = (unit) ->
  new Unit(unit)
Color.from = (type) ->
  new Color(type)

# TODO scopes, functions


TypeGrammar =
  hex:
    regexp: /^#?[0-9A-Fa-f]{3,6}$/
    type: Color
  rgb:
    regexp: /^rgb\((.*)\)/
    type: Color
  rgba:
    regexp: /^rgba\((.*)\)/
    type: Color
  hsl:
    regexp: /^hsl\((.*)\)/
    type: Color
  hsla:
    regexp: /^hsla\((.*)\)/
    type: Color
  unit:
    regexp: /^[-\d]?(\d{1,10})(\S*)$/
    type: Unit
  url:
    regexp: /^url\([\s\S]*\)$/
    type: String
  list:
    regexp: /(\S*\s){1,10}\S*/
    type: List
  text:
    regexp: /(.*)/
    type: String
  
###
OperationGrammar =
  addition:
  subtraction:
  division:
  multiplication:
###

end = ->
  if Compressed then "" else "\n"

class Property
  constructor: (name, value)->
    @name = name
    @value = value
  toString: ->
    @name + ": " + @value.toString() + end()
class Selector 
  constructor: (name, indent) ->
    @basename = name
    @indent = indent
    @extends = []
    @mixins = []
    @props = []
  extend: (selector) ->
    @extends.push selector
  toString: ->
    x = (if @extends.length > 0 then ", " else "" ) + @extends.join ', '
    m =  @basename + x 
    m += @to_p()
  to_p: ->
    m = "{" + end()
    for mixin in @mixins
      Object.merge @props, mixin.block.props
    for k,v of @props
      if typeof v isnt "function"
        m += v.toString()
        #m += k + ": " + v + end()
    m += "}"+end()
    
class Mixin
  constructor: (name, args) ->
    @basename = name
    @args = args
    @vars = []
    @props = []
  to_b: (args) ->
    
  to_s: ->
    ""
  toString: -> ""
    
class Replacer
  constructor: ->
    @identRegexp = /(\s*)/
    @blocks = []
    @is = []
    @vars = {}
    
    @afterParse = []
  
  parse: (text) ->
    scope = []
    lines = text.trim().split("\n")
    for line in lines
      ln = lines.indexOf(line)+1
      indent = line.match(@identRegexp)[1].length or 0
      if indent % 2 isnt 0
        console.warn "Error: Wrong indentation on line #{ln}."
        return false
      if line.length > 0
        for key, val of Grammar 
          if m = line.trim().match val.regexp
            if indent is 0
              scope.empty()
              scope[0] = null
            switch val.scope
              when true
                scope[indent] = null
              when false
                if scope[indent-2] is undefined
                  console.warn "Error: wrong scope on line #{ln}"
                  return false
            args = m[1..]
            args.push indent
            args.push @blocks[@is[indent-2]]
            # TODO all to own functions
            if val.function?
              f = val.function
            else
              f = @[key]
            if val.after
              @afterParse.push {
                func: f
                args: args
              }
            else 
              f.apply @, args
            break
    for st in @afterParse
      st.func.apply @, st.args
    true
  
  # Variable
  variable: (name,value,indent) ->
    @vars[name] = value
  
  # Mixin 
  mixin: (name,args,indent)->
    @is[indent] = name
    @blocks[name] = new Mixin name, args
    
  # extend
  extend: (selector,indent) ->
    @blocks[selector].extend @is[indent-2]
    
  #mixin the mixin
  mix: (name, args, indent)->
    @blocks[@is[indent-2]].mixins.push {
      block: @blocks[name]
      args: args
    }
  
  #property
  property: (name, value, indent) ->
    # replace variables and warn / skip on error
    if value.test /\$\w*/g
      value = value.replace /\$(\w*)/g, =>
        if @vars[arguments[1]] is undefined
          console.warn "Error no variable named #{arguments[1]}"
          return false
        @vars[arguments[1]]
    # TODO operations at this point
    for k, val of TypeGrammar
      if value.trim().test val.regexp
        value = val.type.from value
        break
    @blocks[@is[indent-2]].props[name] = new Property name,value
    
  # selector
  selector: (name, indent) ->
    merged = ""
    if indent isnt 0
      if @is[indent-2] isnt undefined
        merged += @is[indent-2] + " "
    name = name.replace /#\{\$(.*)\}/, =>
      @vars[arguments[1]]
    merged += name
    
    @is[indent] = merged
    sel = new Selector merged, indent
    @blocks[merged] = sel
  
  # compile
  compile: (text) ->
    if @parse text
      m = ""
      for selector, body of @blocks
        if typeof body isnt "function"
          m += body.toString()
      m  
test = fs.readFileSync 'test.sass', 'utf-8'
rep = new Replacer
a = rep.compile(test)   
console.log a
###
fs.watchFile 'test.sass', (curr, prev) ->
  test = fs.readFileSync 'test.sass', 'utf-8'
  rep = new Replacer
  a = rep.compile(test)
  fs.writeFile 'test.css', a
  console.log('File changed: ' + curr.mtime);
###
