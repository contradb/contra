function set_if_unset (dict, key, value) {
    if (!(key in dict))
        dict[key] = value;
}


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


function dialectIsOneToOne(dialect) {
  return isEmpty(dialectOverloadedSubstitutions(dialect));
}

function dialectOverloadedSubstitutions(dialect) {
  var substitutions = {};
  var remember_as_itself = function (x) { substitutions[x] = (substitutions[x] || []).concat([x]); };
  moves().forEach(remember_as_itself);
  dancers().forEach(remember_as_itself);
  [dialect.moves, dialect.dancers].forEach(function(hash) {
    Object.keys(hash).forEach(function(term) {
      var substitution = hash[term];
      substitutions[substitution] = (substitutions[substitution] || []).concat([term]);
    });
  });
  // delete substitutions that are 1-to-1
  for (var substitution in substitutions) {
    if (substitutions.hasOwnProperty(substitution)) {
      if (substitutions[substitution].length === 1)
        delete substitutions[substitution];
    }
  }
  return substitutions;
}

// ________________________________________________________________

function lingoLineMarkup(string, dialect) {
  // lookbehind doesn't work in all versions of js, so we've got to use capture groups for word boundaries, sigh
  var blacklist = /(\s|^)(men|women)(\s|$)/ig;
  var buffer = [];
  var last_match_ended_at;
  while (true) {
    last_match_ended_at = blacklist.lastIndex;
    var match_info = blacklist.exec(string);
    if (!match_info) break;
    buffer.push(string.slice(last_match_ended_at, match_info.index));
    buffer.push(tag('s', match_info[2]));
    blacklist.lastIndex = blacklist.lastIndex - match_info[3].length; // put back trailing whitespace
  }
  buffer.push(string.slice(last_match_ended_at));
  return new Words(buffer);
}

function testLingoLineMarkup(string) {
  var t = 0;
  ++t && (lingoLineMarkup('foomenfoo', null).sanitize() === 'foomenfoo') || throw_up('test '+ t + ' failed');
  ++t && (lingoLineMarkup('foo men foo', null).sanitize() === 'foo <s>men</s> foo') || throw_up('test '+ t + ' failed');
  ++t && (lingoLineMarkup('foo women foo', null).sanitize() === 'foo <s>women</s> foo') || throw_up('test '+ t + ' failed');
  ++t && (lingoLineMarkup('men men', null).sanitize() === '<s>men</s> <s>men</s>') || throw_up('test '+ t + ' failed');
  ++t && (lingoLineMarkup('men salarymen men men', null).sanitize() === '<s>men</s> salarymen <s>men</s> <s>men</s>') || throw_up('test '+ t + ' failed');
  return ''+t+' successful tests';
}

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
  // see also ruby-side implementation
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

function isEmpty(hash) {
  // can't use: hash.length === 0
  for (var x in hash) {
    return false;
  }
  return true;
}
