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
    this.mixins = [];
    this.props = [];
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
    var k, m, mixin, v, _i, _len, _ref, _ref2;
    m = "{" + end();
    _ref = this.mixins;
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      mixin = _ref[_i];
      Object.merge(this.props, mixin.block.props);
    }
    _ref2 = this.props;
    for (k in _ref2) {
      v = _ref2[k];
      if (typeof v !== "function") {
        m += k + ": " + v + end();
      }
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
    var args, indent, key, lastIndent, line, lines, m, val, _i, _len;
    lines = text.trim().split("\n");
    lastIndent = 0;
    for (_i = 0, _len = lines.length; _i < _len; _i++) {
      line = lines[_i];
      indent = line.match(this.identRegexp)[1].length || 0;
      if (indent % 2 !== 0) {
        console.warn("Error: Line " + (lines.indexOf(line)) + " x identation wrong");
        return false;
      }
      if (line.length > 0) {
        for (key in Grammar) {
          val = Grammar[key];
          if (m = line.trim().match(val.regexp)) {
            args = m.slice(1);
            args.push(indent);
            this[key].apply(this, args);
            break;
          }
        }
      }
    }
    return true;
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
    return this.blocks[merged] = sel;
  };
  Replacer.prototype.compile = function(text) {
    var body, m, selector, _ref;
    if (this.parse(text)) {
      m = "";
      _ref = this.blocks;
      for (selector in _ref) {
        body = _ref[selector];
        if (typeof body !== "function") {
          m += body.to_s();
        }
      }
      return m;
    }
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