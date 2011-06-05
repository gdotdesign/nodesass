// MooTools: the javascript framework.
// Load this file's selection again by visiting: http://mootools.net/more/b7d5d5d48336bc0a3e026a4c12686b8c 
// Or build this file again with packager using: packager build More/Color
/*
---

script: More.js

name: More

description: MooTools More

license: MIT-style license

authors:
  - Guillermo Rauch
  - Thomas Aylott
  - Scott Kyle
  - Arian Stolwijk
  - Tim Wienk
  - Christoph Pojer
  - Aaron Newton
  - Jacob Thornton

requires:
  - Core/MooTools

provides: [MooTools.More]

...
*/

MooTools.More = {
	'version': '1.3.2.1',
	'build': 'e586bcd2496e9b22acfde32e12f84d49ce09e59d'
};


/*
---

script: Color.js

name: Color

description: Class for creating and manipulating colors in JavaScript. Supports HSB -> RGB Conversions and vice versa.

license: MIT-style license

authors:
  - Valerio Proietti

requires:
  - Core/Array
  - Core/String
  - Core/Number
  - Core/Hash
  - Core/Function
  - MooTools.More

provides: [Color]

...
*/

(function(){

var HTML4COLORS = {
  'black': "#000000",
  'silver': "#c0c0c0",
  'gray': "#808080",
  'white': "#ffffff",
  'maroon': "#800000",
  'red': "#ff0000",
  'purple': "#800080",
  'fuchsia': "#ff00ff",
  'green': "#008000",
  'lime': "#00ff00",
  'olive': "#808000",
  'yellow': "#ffff00",
  'navy': "#000080",
  'blue': "#0000ff",
  'teal': "#008080",
  'aqua': "#00ffff"
}

var Color = this.Color = new Type('Color', function(color, type){
	if (arguments.length >= 3){
		type = 'rgb'; color = Array.slice(arguments, 0, 3);
	} else if (typeof color == 'string'){
		if (color.match(/rgb/)) color = color.rgbToHex().hexToRgb(true);
		else if (color.match(/hsb/)) color = color.hsbToRgb();
		else color = color.hexToRgb(true);
	}
	type = type || 'rgb';
	switch (type){
		case 'hsb':
			var old = color;
			color = color.hsbToRgb();
			color.hsb = old;
		break;
		case 'hex': color = color.hexToRgb(true); break;
	}
	color.rgb = color.slice(0, 3);
	color.hsb = color.hsb || color.rgbToHsb();
	color.hex = color.rgbToHex();
	return Object.append(color, this);
});

Color.implement({

	mix: function(){
		var colors = Array.slice(arguments);
		var alpha = (typeOf(colors.getLast()) == 'number') ? colors.pop() : 50;
		var rgb = this.slice();
		colors.each(function(color){
			color = new Color(color);
			for (var i = 0; i < 3; i++) rgb[i] = Math.round((rgb[i] / 100 * (100 - alpha)) + (color[i] / 100 * alpha));
		});
		return new Color(rgb, 'rgb');
	},

	invert: function(){
		return new Color(this.map(function(value){
			return 255 - value;
		}));
	},

	setHue: function(value){
		return new Color([value, this.hsb[1], this.hsb[2]], 'hsb');
	},

	setSaturation: function(percent){
		return new Color([this.hsb[0], percent, this.hsb[2]], 'hsb');
	},

	setBrightness: function(percent){
		return new Color([this.hsb[0], this.hsb[1], percent], 'hsb');
	}

});

Color.implement({
  type: 'hex',
  alpha: 100,
  setType: function(type) {
    return this.type = type;
  },
  setAlpha: function(alpha) {
    return this.alpha = alpha;
  },
  hsvToHsl: function() {
    var h, hsl, l, s, v;
    h = this.hsb[0];
    s = this.hsb[1];
    v = this.hsb[2];
    l = (2 - s / 100) * v / 2;
    hsl = [h, s * v / (l < 50 ? l * 2 : 200 - l * 2), l];
    if (isNaN(hsl[1])) {
      hsl[1] = 0;
    }
    return hsl;
  },
  format: function(type) {
    if (type) {
      this.setType(type);
    }
    switch (this.type) {
      case "rgb":
        return String.from("rgb(" + this.rgb[0] + ", " + this.rgb[1] + ", " + this.rgb[2] + ")");
      case "rgba":
        return String.from("rgba(" + this.rgb[0] + ", " + this.rgb[1] + ", " + this.rgb[2] + ", " + (this.alpha / 100) + ")");
      case "hsl":
        this.hsl = this.hsvToHsl();
        return String.from("hsl(" + this.hsl[0] + ", " + (Math.round(this.hsl[1])) + "%, " + (Math.round(this.hsl[2])) + "%)");
      case "hsla":
        this.hsl = this.hsvToHsl();
        return String.from("hsla(" + this.hsl[0] + ", " + (Math.round(this.hsl[1])) + "%, " + (Math.round(this.hsl[2])) + "%, " + (this.alpha / 100) + ")");
      case "hex":
        hex = String.from(this.hex)
        if( (a = Object.keyOf(HTML4COLORS,hex)) !== null){
          return a;
        }
        return hex;
    }
  },
  toString: function() {
    return this.format()
  }
});

this.$RGB = function(r, g, b){
	return new Color([r, g, b], 'rgb');
};

this.$HSB = function(h, s, b){
	return new Color([h, s, b], 'hsb');
};

this.$HEX = function(hex){
	return new Color(hex, 'hex');
};

Array.implement({

	rgbToHsb: function(){
		var red = this[0],
				green = this[1],
				blue = this[2],
				hue = 0;
		var max = Math.max(red, green, blue),
				min = Math.min(red, green, blue);
		var delta = max - min;
		var brightness = max / 255,
				saturation = (max != 0) ? delta / max : 0;
		if (saturation != 0){
			var rr = (max - red) / delta;
			var gr = (max - green) / delta;
			var br = (max - blue) / delta;
			if (red == max) hue = br - gr;
			else if (green == max) hue = 2 + rr - br;
			else hue = 4 + gr - rr;
			hue /= 6;
			if (hue < 0) hue++;
		}
		return [Math.round(hue * 360), Math.round(saturation * 100), Math.round(brightness * 100)];
	},

	hsbToRgb: function(){
		var br = Math.round(this[2] / 100 * 255);
		if (this[1] == 0){
			return [br, br, br];
		} else {
			var hue = this[0] % 360;
			var f = hue % 60;
			var p = Math.round((this[2] * (100 - this[1])) / 10000 * 255);
			var q = Math.round((this[2] * (6000 - this[1] * f)) / 600000 * 255);
			var t = Math.round((this[2] * (6000 - this[1] * (60 - f))) / 600000 * 255);
			switch (Math.floor(hue / 60)){
				case 0: return [br, t, p];
				case 1: return [q, br, p];
				case 2: return [p, br, t];
				case 3: return [p, q, br];
				case 4: return [t, p, br];
				case 5: return [br, p, q];
			}
		}
		return false;
	}

});

String.implement({

	rgbToHsb: function(){
		var rgb = this.match(/\d{1,3}/g);
		return (rgb) ? rgb.rgbToHsb() : null;
	},

	hsbToRgb: function(){
		var hsb = this.match(/\d{1,3}/g);
		return (hsb) ? hsb.hsbToRgb() : null;
	}

});

})();


