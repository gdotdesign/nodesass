mixin = (name) ->
  Mixins[name] =

selector = (name, properties) ->
  Selectors[name] 
  
extend = (name) ->
  

selector:after
  +somethingElse
  :background-color black
  
selector "h2", ->
  mixin somethingElse
  extend ".basic"
  property "background-color", "black"
  selector "&:after"
    property "background-color", "white"
