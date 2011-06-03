Grammar = exports
grammar =
  variable:
    regexp: /^\$(.*):\s(.*)$/
    scope: null
    function: (name,value,indent) ->
      @vars[name] = value
    after: false
  property:
    regexp: /^:(.*?)\s(.*)$/
    scope: false
    after: false
  extend:
    regexp: /@extends\s(.*)$/
    scope: false
    function: (name, indent, b) ->
      currentBlock = b.basename
      for n, block of @blocks
        if n.test new RegExp("^#{name}")
          block.extends.push block.basename.replace new RegExp("^#{name}"), currentBlock
    after: true
  iteration:
    regexp: /@for\s(.*)$/
    scope: true
    after: false
  conditinal:
    regexp: /@if\s(.*)$/
    scope: true
    after: false
  mixin:
    regexp: /^=(.*)\((.*)\)$/
    scope: true
    after: false
  mix:
    regexp: /^\+(.*)\((.*)\)$/
    scope: false
    after: false
  selector:
    regexp: /(.*)/
    scope: true
    after: false
Object.merge Grammar, grammar

