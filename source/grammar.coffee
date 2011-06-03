require './classes/Selector'
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
Grammar = exports
Compressed = false
end = ->
  if Compressed then "" else "\n"
Object.merge Grammar, {
  variable:
    regexp: /^\$(.*):\s(.*)$/
    scope: null
    function: (name,value,indent) ->
      @vars[name] = value
    after: false
    block: false
  property:
    regexp: /^:(.*?)\s(.*)$/
    scope: false
    after: false
    block: false
  extend:
    regexp: /@extends\s(.*)$/
    scope: false
    function: (name, indent, b) ->
      currentBlock = b.basename
      for n, block of @blocks
        if n.test new RegExp("^#{name}")
          block.extends.push block.basename.replace new RegExp("^#{name}"), currentBlock
    after: true
    block: false
  iteration:
    regexp: /@for\s(.*)$/
    scope: true
    after: false
    block: true
  conditinal:
    regexp: /@if\s(.*)$/
    scope: true
    after: false
    block: true
  mixin:
    regexp: /^=(.*)\((.*)\)$/
    scope: true
    after: false
    block: true
  mix:
    regexp: /^\+(.*)\((.*)\)$/
    scope: false
    after: false
    block: false
    function: (name, args, indent, block,ln)->
      mb = (@blocks.filter (b) -> b.basename is name)[0]
      if mb?
        block.mixins.push {
          block: mb
          args: args
        }
      else
        throw "ERROR: No mixin named '#{name}' on line #{ln}"
  selector:
    regexp: /(.*)/
    scope: true
    after: false
    block: true
    function: (name, indent, block, ln) ->
      merged = ""
      if indent isnt 0
        if block isnt undefined
          merged += block.basename + " "
      name = name.replace /#\{\$(.*)\}/, =>
        @vars[arguments[1]]
      merged += name
      
      new Selector merged, indent
}

