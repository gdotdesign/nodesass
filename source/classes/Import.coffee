exports.Import = class Import
  constructor: (filename)->
    @name = filename
  toString: -> 
    "@import " + @name + ";\n"
