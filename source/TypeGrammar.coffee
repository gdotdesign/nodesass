require 'mootools'
require '../lib/mootoolsColor'
{Unit} = require './types/Unit'
{List} = require './types/List'

Color.from = (type) ->
  new Color(type)

exports.TypeGrammar =
  number:
    regexp: /^\d*$/
    type: Number
  hex:
    regexp: /^#?[0-9A-Fa-f]{3,6}$/
    type: Color
  rgb:
    regexp: /^rgb\((.*)\)/
    type: Color
  rgba:
    regexp: /^rgba\((.*)\)/
    type: Color
  hsl:
    regexp: /^hsl\((.*)\)/
    type: Color
  hsla:
    regexp: /^hsla\((.*)\)/
    type: Color
  unit:
    regexp: /^[-\d|\.\d]?(\d{1,10})(\S*)$/
    type: Unit
  url:
    regexp: /^url\([\s\S]*\)$/
    type: String
  list:
    regexp: /(\S*\s){1,10}\S*/
    type: List
  text:
    regexp: /(.*)/
    type: String
