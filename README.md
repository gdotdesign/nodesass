(name pending)
========

The goal of this repo is to create a Sass like Stylesheet compiler for use within node.js written in CoffeeScript 
(with Sass compability).

## What works?

 *  Properties
 *  Selector nesting 
 *  Varaiables (partially)
 *  Mixins (whitout variables, no nesting)
 *  Nested Properties
 *  @extend (partially)
 *  @import (everything except rules with media queries)
 *  Referencing parent selectors
 *  Data types (preliminary)
 
## What isn't?
  
 *  @media
 *  Lists
 *  Operations
 *  Control Directives
 *  Function Directives
 
## Features will include

 *  CLI
 *  Caching
 *  NPM package
 *  Custom block and line parsers

## Required NPM packages

 *  mootools (server side)
 *  coffee-script
 *  mootools-slick-parser 
 
### Test cases
 
This repo need some good test cases to compare with Sass compiled CSS. Tesing will include specs and automatic comparisson between this and Sass.

Current test cases:

#### Sass tests from github repo: [Templates](https://github.com/nex3/sass/tree/master/test/sass/templates), [Results](https://github.com/nex3/sass/tree/master/test/sass/results)

#### Theme stylsheets for [Lattice](https://github.com/gdotdesign/Lattice/tree/master/Themes/Blender): 
 
 *  extensinve extends
 *  referencing parent selectors
 *  variables
 *  color functions
     
### Name

This compiler needs a name! 
