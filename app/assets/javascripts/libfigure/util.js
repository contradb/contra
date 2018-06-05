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

Words.prototype.sanitize = function() {
  return wordsClassic.apply(null, this.arr.map(sanitizeAnything));
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
    });
  } else {
    return s;                   // c.f. comma, false
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

// take words, put them in strings, return a big, space separated string of them all. 
function wordsClassic() {
  if (arguments.length <= 0) return "";
  else {
    var acc = (arguments[0] === false) ? '' : arguments[0];
    var i;
    for (i=1; i<arguments.length; i++) {
      if (comma === arguments[i]) {
        acc = acc.trim() + ',';
      } else if (arguments[i] !== false) {
        acc += " ";
        acc += arguments[i];
      }
    }
    return acc;
  }
}

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

function comma_unless_blank(str) {
  return ((!str) || (str.trim() === '')) ? '' : ',';
}

function indefiniteArticleFor(str) {
  return /^ *[aeiou]/.test(str) ? 'an' : 'a';
}


var defaultDialect = {moves: {}, dancers: {}};

var testDialect = {moves: {gyre: 'darcy',
                           allemande: 'almond',
                           'see saw': 'do si do left shoulder',
                           'form an ocean wave': 'form a short wavy line'},
                   dancers: {ladles: 'ravens',
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
          moves: libfigureObjectCopy(dialect.moves)};
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
