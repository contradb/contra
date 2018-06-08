var _contraHtmlEscapeRegEx = /[<>&]/g;

function escapehtml(string) {
  if (string.match(_contraHtmlEscapeRegEx)) {
    return string.replace(_contraHtmlEscapeRegEx, function(s) {
      switch(s) {
      case '<': return '&lt;';
      case '>': return '&gt;';
      case '&': return '&amp;';
      default: return s;
      }
    });
  } else {
    return string;
  }
}


function set_if_unset (dict, key, value) {
    if (!(key in dict))
        dict[key] = value;
}

////////////////////////////////////////////////////////////////

function Words(arr) {
  this.arr = arr;
}

function words () {
  return new Words(Array.prototype.slice.call(arguments));
}

var wants_no_space_before = [false, null, ',', '.', ';'];

Words.prototype.sanitize = function() {
  var arr = this.arr;
  var acc = [];
  var space_before = false;
  for (var i=0; i<arr.length; i++) {
    var wants_space_before = -1 === wants_no_space_before.indexOf(peek(arr[i]));
    if (wants_space_before) {
      acc.push(' ');
    }
    acc.push(sanitizeAnything(arr[i]));
  }
  return acc.join('').trim();// wordsClassic.apply(null, this.arr.map(sanitizeAnything));
}

Words.prototype.peek = function() {
  for (var i = 0; i < this.arr.length; i++) {
    var p = peek(this.arr[i]);
    if (p) {
      return p;
    }
  }
  return null;
}

Words.prototype.isWord = true;

function Tag(tag, attrs, body) {
  this.tag = tag;
  this.attrs = attrs;
  this.body = body;
}

function tag(tag, attrs_or_body, body_or_nothing) {
  var attrs;
  var body;
  if (body_or_nothing==undefined) {
    body = attrs_or_body;
    attrs = {};
  } else {
    body = body_or_nothing;
    attrs = attrs_or_body;
  }
  return new Tag(tag, attrs, body);
}

Tag.prototype.sanitize = function () {
  // TODO: attrs
  return '<' + this.tag + '>' + sanitizeAnything(this.body) + '</' + this.tag + '>';
}

Tag.prototype.peek = function () {
  return peek(this.body);
}

Tag.prototype.isTag = true;

var sanitizationMap = {
  '<': '&lt;',
  '>': '&gt;',
  '&': '&amp;',
  '&amp;': '&amp;'
};

function sanitizeAnything(s) {
  if (s.sanitize) {
    return s.sanitize();
  } else if ('string' === typeof s) {
    return s.replace(/&amp;|&|<|>/g, function(match) {
      return sanitizationMap[match] || throw_up('Unexpected match during sanitize');
    }).trim();
  } else if (comma === s) {
    return ',';
  } else if (false === s) {
    return '';
  } else {
    return ''+s;
  }
}

// returns first non-whitespace character
function peek(thing) {
  var m;
  if (thing.peek) {
    return thing.peek();
  } else if ((typeof thing === 'string') && (m = thing.match(/\S/))) {
    return m[0];
  } else if (thing == comma) {
    return ',';
  } else if (thing == false) {
    return null;
  } else {
    return null;
  }
}

// function test_sanitize() {
//   (words('<p>hi & stuff</p>').sanitize() == '&lt;p&gt;hi &amp; stuff&lt;/p&gt;') || throw_up('test 1 failed');
//   (new Tag('p', {}, 'hi & stuff').sanitize() == '<p>hi &amp; stuff</p>') || throw_up('test 2 failed');
//   (words('hello', tag('p', 'hi & stuff'), 'hello').sanitize() == 'hello <p>hi &amp; stuff</p> hello') || throw_up('test 3 failed');
//   (words('mad robin', false, comma, 'gentlespoons in front').sanitize() == 'mad robin, gentlespoons in front') || throw_up('test 4 failed');
//   return 'success';
// }

// function test_peek() {
//   var t = 0;
//   ++t && (peek(' ') === null) || throw_up('test '+ t + ' failed');
//   ++t && (peek(' hi') === 'h') || throw_up('test '+ t + ' failed');
//   ++t && (peek(words(false, '   ', 'hi')) === 'h') || throw_up('test '+ t + ' failed');
//   ++t && (peek(words(false, '   ', comma)) === ',') || throw_up('test '+ t + ' failed');
//   ++t && (peek(tag('i', 'hi')) === 'h') || throw_up('test '+ t + ' failed');
//   ++t && (peek(words(words('  '), words(false), words('hi'))) === 'h') || throw_up('test '+ t + ' failed');
//   return 'success';
// }

////////////////////////////////////////////////////////////////

var comma = ['comma'];

// Patch to support current IE, source http://stackoverflow.com/questions/31720269/internet-explorer-11-object-doesnt-support-property-or-method-isinteger
isInteger = Number.isInteger || function(value) {
    return typeof value === "number" && 
           isFinite(value) && 
           Math.floor(value) === value;
};

// throw is a keyword and can't be in expressions, but function calls can be, so wrap throw.
function throw_up(str) {
  throw new Error(str);
}

// a little weird that this takes a Words now, not a string
function indefiniteArticleFor(w) {
  var str = peek(w);
  return /[aeiou]/.test(str) ? 'an' : 'a';
}

// text_in_dialect: <bool> property can still be missing...
var defaultDialect = {moves: {}, dancers: {}};

var testDialect = {moves: {gyre: 'darcy',
                           allemande: 'almond',
                           'see saw': 'do si do left shoulder',
                           'form an ocean wave': 'form a short wavy line'},
                   dancers: {ladle: 'raven',
                             ladles: 'ravens',
                             gentlespoon: 'lark',
                             gentlespoons: 'larks',
                             'first ladle': 'first raven',
                             'second ladle': 'second raven',
                             'first gentlespoon': 'first lark',
                             'second gentlespoon': 'second lark'}};

// ________________________________________________________________



function dialectForFigures(dialect, figures) {
  var new_dialect = copyDialect(dialect);
  if (figuresUseDancers(figures, '3rd neighbors')) {
    new_dialect.dancers['neighbors']      = '1st neighbors';
    new_dialect.dancers['next neighbors'] = '2nd neighbors';
  }
  if (figuresUseDancers(figures, '2nd shadows')) {
    new_dialect.dancers['shadows'] = '1st shadows';
  }
  return new_dialect;
}

function copyDialect(dialect) {
  return {dancers: libfigureObjectCopy(dialect.dancers),
          moves: libfigureObjectCopy(dialect.moves),
          text_in_dialect: !!dialect.text_in_dialect};
}

function textInDialect(dialect) {
  return !!dialect.text_in_dialect;
}

// I just called this function 'copy', but then I got scared and changed it.
function libfigureObjectCopy(hash) {
  var o = {};
  Object.keys(hash).forEach(function(key) {
    o[key] = hash[key];
  });
  return o;
}

function libfigureUniq(array) { // suboptimal O(n^2)
  var output = [];
  for (var i=0; i<array.length; i++) {
    if (-1 === output.indexOf(array[i])) {
      output.push(array[i]);
    }
  }
  return output;
}

// // every element is ===
// function array_equal(a1, a2) {
//   var l = a1.length;
//   if (l !== a2.length) {
//     return false;
//   }
//   for (var i=0; i<l; i++) {
//     if (a1[i] !== a2[i]) {
//       return false;
//     }
//   }
//   return true;
// }

// used to determine if a dance uses the term 'shadow' or '3rd neighbor'
function figuresUseDancers(figures, dancers_term) {
  for (var figi=0; figi<figures.length; figi++) {
    var figure = figures[figi];
    var formals = parameters(figure.move);
    for (var i=0; i < formals.length; i++) {
      var formal = formals[i];
      var actual = figure.parameter_values[i];
      if (formalParamIsDancers(formal) && (dancers_term === actual)) {
        return true;
      }
    }
  }
  return false;
}

// see also the similar ruby-side function slugify_move 
function slugifyTerm(term) {
  return term.toLowerCase().replace(/&/g, 'and').replace(/ /g, '-').replace(/[^a-z0-9-]/g, '');
}

// ________________________________________________________________

var regExpEscape_regexp = /[-\/\\^$*+?.()|[\]{}]/g;
function regExpEscape(s) {
  return s.replace(regExpEscape_regexp, '\\$&');
};
// source https://stackoverflow.com/questions/3561493/is-there-a-regexp-escape-function-in-javascript/3561711#3561711
