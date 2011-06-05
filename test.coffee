fs = require 'fs'
assert = require('assert');
{Replacer} = require "./sasscompile"
compiler = new Replacer()

template = fs.readFileSync 'test/Sass/templates/basic.sass', 'utf-8'
eresult = fs.readFileSync 'test/Sass/results/basic.css', 'utf-8'

#template = fs.readFileSync 'test/Sass/templates/complex.sass', 'utf-8'
#eresult = fs.readFileSync 'test/Sass/results/complex.css', 'utf-8'

fs.writeFileSync 'test/Sass/cache/eresult', eresult
result = compiler.compile template
fs.writeFileSync 'test/Sass/cache/result', result

#console.log compiler.blocks
console.log eresult == result
