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
    @b = []
    @afterParse = []
  
  parse: (text) ->
    scope = []
    lines = text.trim().split("\n")
    try
      for line in lines
        ln = lines.indexOf(line)+1
        indent = line.match(@identRegexp)[1].length or 0
        if indent % 2 isnt 0
          throw "Error: Wrong indentation on line #{ln}."
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
                    throw "Error: wrong scope on line #{ln}"
              args = m[1..]
              args.push indent
              args.push @b[indent-2]
              args.push ln
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
                b = f.apply @, args
              if val.block
                @b[indent] = b
                @blocks.push b
              break
      for st in @afterParse
        st.func.apply @, st.args
    catch e
      console.warn e
      return false
    true
  
  # Variable
  variable: (name,value,indent) ->
    @vars[name] = value
  
  # Mixin 
  mixin: (name,args,indent)->
    new Mixin name, args
    
  #property
  property: (name, value, indent, block, ln) ->
    # replace variables and warn / skip on error
    if value.test /\$\w*/g
      value = value.replace /\$(\w*)/g, =>
        if @vars[arguments[1]] is undefined
          throw "Error no variable named #{arguments[1]} on line #{ln}"
        @vars[arguments[1]]
    # TODO operations at this point
    for k, val of TypeGrammar
      if value.trim().test val.regexp
        value = val.type.from value
        break
    block.props[name] = new Property name,value
    
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
