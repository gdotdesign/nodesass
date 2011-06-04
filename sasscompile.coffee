fs = require 'fs'
sys = require 'sys'
require 'mootools'
coffee = require 'coffee-script'
require './lib/mootoolsColor'

{Grammar} = require './source/Grammar'
{SCOPE} = require './source/Constans'

Compressed = false
###
OperationGrammar =
  addition:
  subtraction:
  division:
  multiplication:
###

class Replacer
  constructor: (path) ->
    @identRegexp = /(\s*)/
    @path = path
    @blocks = []
    @is = []
    @vars = {}
    @b = []
    @afterParse = []
  
  parse: (text, full) ->
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
                scope[0] = undefined
              switch val.scope
                when SCOPE.BLOCK
                  scope[indent] = null
                when SCOPE.INBLOCK
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
              if typeof b is 'object'
                @b[indent] = b
                @blocks.push b
              break
      unless full
        for st in @afterParse
          st.func.apply @, st.args
    catch e
      console.warn e
      return false
    true
    
  # compile
  compile: (text) ->
    if @parse text
      m = ""
      for selector, body of @blocks
        if typeof body isnt "function"
          m += body.toString()
      m  
test = fs.readFileSync 'test/Blender/theme.sass', 'utf-8'
rep = new Replacer 'test/Blender/'
a = rep.compile(test)   
if Compressed
  b = ""
  for line in a.split("\n")
    b += line.trim()
  a = b
#console.log a
fs.writeFile 'test.css', a
###
fs.watchFile 'test.sass', (curr, prev) ->
  test = fs.readFileSync 'test.sass', 'utf-8'
  rep = new Replacer
  a = rep.compile(test)
  fs.writeFile 'test.css', a
  console.log('File changed: ' + curr.mtime);
###
