sys = require 'sys'
fs = require 'fs'
require 'mootools'

{Slick} = require '../lib/Slick'

{Selector} = require './classes/Selector'
{Import} = require './classes/Import'
{Mixin} = require './classes/Mixin'
{Property} = require './classes/Property'
{TypeGrammar} = require './TypeGrammar'

{SCOPE} = require './Constans'

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
        else
          a += e.tag
      if e.pseudos
        for p in e.pseudos
          a += ":"+p.key
          if p.value isnt null
            a += "(#{p.value})"
  a.trim()
compareExpressions = (a,b) ->
  ret = false
  if a.length is b.length
    for i in [0..a.length-1]
      c = a[i]
      d = b[i]
      ret = compareSubExp c, d
  ret
compareSubExp = (c,d) ->
  # TODO pseudos
  if c.combinator is d.combinator and c.tag is d.tag
    if c.id? and d.id?
      if c.id isnt c.id
        return false
    else
      if c.id? or d.id? 
        return false
    if c.classList? and d.classList?
      if c.classList.length is d.classList.length
        for j in [0..c.classList.length-1]
          e = c.classList[j]
          if d.classList.indexOf(e) is -1
            return false
      return true
    else
      return true
  false
exports.Grammar = 
  comment: 
    regexp: /^\/\/(.*)$/
    scope: SCOPE.INDENTED
    function: -> false
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
  extend:
    regexp: /@extend\s(.*)$/
    scope: SCOPE.INBLOCK
    function: (name, indent, b) ->
      currentBlock = b.name
      name = name.replace /#\{\$(.*?)\}/g, =>
        @vars[arguments[1]]
      d = Slick.parse name
      for block in @blocks
        try
          for a in d.expressions
            for c in block.parsed.expressions
              if compareExpressions a, c
                # g is the found expression to be replaced with b.parsed.expressions
                pseudos = c.getLast().pseudos
                g = Array.clone b.parsed.expressions
                g.each (it) ->
                  h = it.getLast()
                  if h.pseudos is undefined
                    h.pseudos = []
                  h.pseudos.append pseudos
                block.parsed.expressions.append g
        catch e
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
      block.props.push {
        block: mb
        args: args
      }
      false
  reference:
    regexp: /^&(.*)/
    scope: SCOPE.BLOCK
    function: (name, indent, block, ln) ->
      #name = block.name+name
      name = name.replace /#\{\$(.*?)\}/g, =>
        @vars[arguments[1]]
      s = new Selector name, indent
      s.parsed = Slick.parse name
      np = Object.clone block.parsed
      # fix for multiple expressions
      try
        for e in np.expressions
          for e2 in s.parsed.expressions
            e.getLast().classList.append e2.getLast().classList
            if e2.getLast().pseudos
             if e.getLast().pseudos is undefined
                e.getLast().pseudos = e2.getLast().pseudos
             else
               Object.merge e.getLast().pseudos, e2.getLast().pseudos
      catch e
        console.log e
      s.parsed = np
      s
  property:
    regexp: [/^:(.*?)\s(.*)$/,/^(.*?):\s(.*)$/]
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
      block.props.push new Property name,value
      false
  selector:
    regexp: /(.*)/
    scope: SCOPE.BLOCK
    function: (name, indent, block, ln) ->
      name = name.replace /#\{\$(.*?)\}/g, =>
        @vars[arguments[1]]

      s = new Selector name, indent
      s.parsed = Slick.parse name
      if s.parsed isnt null
        if s.parsed.raw isnt null
          ret = {
            Slick: true
            expressions: []
            raw: ""
          }
          try
            a = Object.clone(block.parsed)
            for b in a.expressions
              for c in s.parsed.expressions
                d = Array.clone b
                d.append c
                ret.expressions.push d
            s.parsed = ret
          return s
      false
