var Compressed, Grammar, Mixin, Replacer, Selector, a, coffee, end, fs, rep, sasscompile, sys, test;
var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };
fs = require('fs');
sys = require('sys');
require('mootools');
coffee = require('coffee-script');
sasscompile = exports;
Compressed = false;
Grammar = {
  variable: {
    regexp: /^\$(.*):\s(.*)$/
  },
  property: {
    regexp: /^:(.*?)\s(.*)$/
  },
  extend: {
    regexp: /@extends\s(.*)$/
  },
  mixin: {
    regexp: /^=(.*)\((.*)\)$/
  },
  mix: {
    regexp: /^\+(.*)\((.*)\)$/
  },
  selector: {
    regexp: /(.*)/
  }
};
end = function() {
  if (Compressed) {
    return "";
  } else {
    return "\n";
  }
};
Selector = (function() {
  function Selector(name, indent) {
    this.basename = name;
    this.indent = indent;
    this["extends"] = [];
    this.cextends = [];
    this.mixins = [];
    this.props = [];
    this.blocks = [];
  }
  Selector.prototype.extend = function(selector) {
    return this["extends"].push(selector);
  };
  Selector.prototype.to_s = function() {
    var m, x;
    x = (this["extends"].length > 0 ? ", " : "") + this["extends"].join(', ');
    m = this.basename + x;
    return m += this.to_p();
  };
  Selector.prototype.to_p = function() {
    var k, m, v, _ref;
    m = "{" + end();
    _ref = this.props;
    for (k in _ref) {
      v = _ref[k];
      m += k + ": " + v + end();
    }
    return m += "}" + end();
  };
  return Selector;
})();
Mixin = (function() {
  function Mixin(name, args) {
    this.basename = name;
    this.args = args;
    this.vars = [];
    this.props = [];
  }
  Mixin.prototype.to_b = function(args) {};
  Mixin.prototype.to_s = function() {
    return "";
  };
  return Mixin;
})();
Replacer = (function() {
  function Replacer() {
    this.identRegexp = /(\s*)/;
    this.blocks = [];
    this.is = [];
    this.vars = {};
  }
  Replacer.prototype.parse = function(text) {
    var args, key, line, lines, m, val, _i, _len, _results;
    lines = text.trim().split("\n");
    _results = [];
    for (_i = 0, _len = lines.length; _i < _len; _i++) {
      line = lines[_i];
      _results.push((function() {
        var _results;
        if (line.length > 0) {
          _results = [];
          for (key in Grammar) {
            val = Grammar[key];
            if (m = line.trim().match(val.regexp)) {
              args = m.slice(1, (m.length + 1) || 9e9);
              args.push(line.match(this.identRegexp)[1].length || 0);
              this[key].apply(this, args);
              break;
            }
          }
          return _results;
        }
      }).call(this));
    }
    return _results;
  };
  Replacer.prototype.variable = function(name, value, indent) {
    return this.vars[name] = value;
  };
  Replacer.prototype.mixin = function(name, args, indent) {
    this.is[indent] = name;
    return this.blocks[name] = new Mixin(name, args);
  };
  Replacer.prototype.extend = function(selector, indent) {
    return this.blocks[selector].extend(this.is[indent - 2]);
  };
  Replacer.prototype.mix = function(name, args, indent) {
    return this.blocks[this.is[indent - 2]].mixins.push({
      block: this.blocks[name],
      args: args
    });
  };
  Replacer.prototype.property = function(name, value, indent) {
    var a;
    if (a = value.match(/^\$(.*)$/)) {
      value = this.vars[a[1]];
    }
    return this.blocks[this.is[indent - 2]].props[name] = value;
  };
  Replacer.prototype.selector = function(name, indent) {
    var merged, sel;
    merged = "";
    if (indent !== 0) {
      if (this.is[indent - 2] !== void 0) {
        merged += this.is[indent - 2] + " ";
      }
    }
    name = name.replace(/#\{\$(.*)\}/, __bind(function() {
      return this.vars[arguments[1]];
    }, this));
    merged += name;
    this.is[indent] = merged;
    sel = new Selector(merged, indent);
    if (this.is[indent - 2] !== void 0) {
      this.blocks[this.is[indent - 2]].blocks.push(sel);
    }
    return this.blocks[merged] = sel;
  };
  Replacer.prototype.compile = function(text) {
    var body, m, selector, _ref;
    this.parse(text);
    m = "";
    _ref = this.blocks;
    for (selector in _ref) {
      body = _ref[selector];
      m += body.to_s();
    }
    return m;
  };
  return Replacer;
})();
test = fs.readFileSync('test.sass', 'utf-8');
rep = new Replacer;
a = rep.compile(test);
console.log(a);
/*
fs.watchFile 'test.sass', (curr, prev) ->
  test = fs.readFileSync 'test.sass', 'utf-8'
  rep = new Replacer
  a = rep.compile(test)
  fs.writeFile 'test.css', a
  console.log('File changed: ' + curr.mtime);
*/