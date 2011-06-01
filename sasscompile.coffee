fs = require 'fs'
sys = require 'sys'
require 'mootools'
coffee = require 'coffee-script'
sasscompile = exports
Compressed = false

Grammar =
  variable:
    regexp: /^\$(.*):\s(.*)$/
  property:
    regexp: /^:(.*?)\s(.*)$/
  extend:
    regexp: /@extends\s(.*)$/
  mixin:
    regexp: /^=(.*)\((.*)\)$/
  mix:
    regexp: /^\+(.*)\((.*)\)$/
  selector:
    regexp: /(.*)/

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
    lines = text.trim().split("\n")
    for line in lines
      if line.length > 0
        for key, val of Grammar 
          if m = line.trim().match val.regexp
            args = m[1..m.length]
            args.push(line.match(@identRegexp)[1].length || 0)
            @[key].apply @, args
            break
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
    @parse text
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
