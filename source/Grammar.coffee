sys = require 'sys'
fs = require 'fs'
require 'mootools'
{Selector} = require './classes/Selector'
{Import} = require './classes/Import'
{Mixin} = require './classes/Mixin'
{Property} = require './classes/Property'
{TypeGrammar} = require './TypeGrammar'

{SCOPE} = require './Constans'
exports.Grammar = 
  variable:
    regexp: /^\$(.*):\s(.*)$/
    scope: SCOPE.INDENTED
    function: (name,value,indent) ->
      @vars[name] = value
      false
  import:
    regexp: /@import\s(.*)$/
    scope: SCOPE.BLOCK
    function: (file,indent,block,ln) ->
      imp = true
      imp = false if file.test /\.css$/ 
      imp = false if file.test /http:\\\\/
      imp = false if file.test TypeGrammar.url.regexp
      # TODO media queries
      #imp = false unless 
      if imp
        try
          text = fs.readFileSync(@path+"/"+file, 'utf-8')
        catch e
          throw "No file!" + e
        try
          @parse text, true
        catch e
          console.log e
          throw e
      else
        new Import file
  property:
    regexp: /^:(.*?)\s(.*)$/
    scope: SCOPE.INBLOCK
    function: (name, value, indent, block, ln) ->
      # replace variables and warn / skip on error
      if block.vars
        vars1 = Object.merge @vars, block.vars
      else
        vars1 = @vars
      if value.test /\$\w*/g
        value = value.replace /\$(\w*)/g, =>
          if vars1[arguments[1]] is undefined
            throw "Error no variable named #{arguments[1]} on line #{ln}"
          vars1[arguments[1]]
      # TODO operations at this point
      for k, val of TypeGrammar
        if value.trim().test val.regexp
          value = val.type.from value
          break
      block.props[name] = new Property name,value
      false
  extend:
    regexp: /@extend\s(.*)$/
    scope: SCOPE.INBLOCK
    function: (name, indent, b) ->
      currentBlock = b.name
      for n, block of @blocks
        if block.name?
          if block.name.test new RegExp("^#{name}")
            block.extends.push block.name.replace new RegExp("^#{name}"), currentBlock
      false
    after: true
  iteration:
    regexp: /@for\s(.*)$/
    scope: SCOPE.BLOCK
  conditinal:
    regexp: /@if\s(.*)$/
    scope: SCOPE.BLOCK
  mixin:
    regexp: /^=(.*)\((.*)\)$/
    scope: SCOPE.BLOCK
    function: (name,args,indent)->
      new Mixin name, args  
  mix:
    regexp: /^\+(.*?)\((.*)\)$/
    scope: SCOPE.INBLOCK
    function: (name, args, indent, block,ln)->
      mb = (@blocks.filter (b) -> b.name is name)[0]
      throw "ERROR: No mixin named '#{name}' on line #{ln}" unless mb?
      block.mixins.push {
        block: mb
        args: args
      }
      false
  reference:
    regexp: /^&(.*)/
    scope: SCOPE.BLOCK
    function: (name, indent, block, ln) ->
      name = block.name+name
      name = name.replace /#\{\$(.*?)\}/g, =>
        @vars[arguments[1]]
      new Selector name, indent
  selector:
    regexp: /(.*)/
    scope: SCOPE.BLOCK
    function: (name, indent, block, ln) ->
      merged = ""
      if indent isnt 0
        if block isnt undefined
          merged += block.name + " "
      name = name.replace /#\{\$(.*?)\}/g, =>
        @vars[arguments[1]]
      merged += name
      
      new Selector merged, indent
