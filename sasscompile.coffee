fs = require 'fs'
sys = require 'sys'
require 'mootools'
coffee = require 'coffee-script'
sasscompile = exports

Compressed = false

Grammar =
  variable:
    regexp: /^\$(.*):\s(.*)$/
    scope: null
  property:
    regexp: /^:(.*?)\s(.*)$/
    scope: false
  extend:
    regexp: /@extends\s(.*)$/
    scope: false
  mixin:
    regexp: /^=(.*)\((.*)\)$/
    scope: true
  mix:
    regexp: /^\+(.*)\((.*)\)$/
    scope: false
  selector:
    regexp: /(.*)/
    scope: true

end = ->
  if Compressed then "" else "\n"

class Selector 
  constructor: (name, indent) ->
    @basename = name
    @indent = indent
    @extends = []
    @mixins = []
    @props = []
  extend: (selector) ->
    @extends.push selector
  to_s: ->
    x = (if @extends.length > 0 then ", " else "" ) + @extends.join ', '
    m =  @basename + x 
    m += @to_p()
  to_p: ->
    m = "{" + end()
    for mixin in @mixins
      Object.merge @props, mixin.block.props
    for k,v of @props
      if typeof v isnt "function"
        m += k + ": " + v + end()
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
class Replacer
  constructor: ->
    @identRegexp = /(\s*)/
    @blocks = []
    @is = []
    @vars = {}
  
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
            @[key].apply @, args
            break
    true
  variable: (name,value,indent) ->
    @vars[name] = value
  mixin: (name,args,indent)->
    @is[indent] = name
    @blocks[name] = new Mixin name, args
  extend: (selector,indent) ->
    @blocks[selector].extend @is[indent-2]
  mix: (name, args, indent)->
    @blocks[@is[indent-2]].mixins.push {
      block: @blocks[name]
      args: args
    }
  property: (name, value, indent) ->
    if a = value.match /^\$(.*)$/
      value = @vars[a[1]]
    @blocks[@is[indent-2]].props[name] = value
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
  compile: (text) ->
    if @parse text
      m = ""
      for selector, body of @blocks
        if typeof body isnt "function"
          m += body.to_s()
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
