fs = require 'fs'
assert = require('assert');
{Replacer} = require "./sasscompile"
compiler = new Replacer()

list = fs.readdirSync 'test/Sass/templates'
for f in list 
  template = fs.readFileSync 'test/Sass/templates/'+f, 'utf-8'
  eresult = fs.readFileSync 'test/Sass/results/'+f.replace(/\.sass$/, ".css"), 'utf-8'
  result = compiler.compile template
  fs.writeFileSync 'test/Sass/cache/'+f.replace(/\.sass$/, ".css"), result
  console.log "Testing #{f}:", if eresult == result then "OK" else "FAILED"
