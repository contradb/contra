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
  var regex = /(\s|^)(men|women)(\s|$)/ig;
  var underlines_and_strikes = underlinesAndStrikes(dialect);
  var all_lingo_lines = underlines_and_strikes.underlines.concat(underlines_and_strikes.strikes).sort(longestFirstSortFn);
                      // new Regex((space)(map(join '|' . quote $ underlines + strikes))(space))
  regex = new RegExp('(\\s|^)(' + all_lingo_lines.map(regExpEscape).join('|') + ')(\\s|$)','ig');
  var buffer = [];
  var last_match_ended_at;
  while (true) {
    last_match_ended_at = regex.lastIndex;
    var match_info = regex.exec(string);
    if (!match_info) break;
    buffer.push(string.slice(last_match_ended_at, match_info.index));
    var is_strike = underlines_and_strikes.strikes.indexOf(match_info[2].toLowerCase()) >= 0;
    buffer.push(tag(is_strike ? 's' : 'u', match_info[2]));
    regex.lastIndex = regex.lastIndex - match_info[3].length; // put back trailing whitespace
  }
  buffer.push(string.slice(last_match_ended_at));
  return new Words(buffer);
}

function testLingoLineMarkup(string) {
  var d = testDialect;
  var t = 0;
  ++t && (lingoLineMarkup('foomenfoo', d).sanitize() === 'foomenfoo') || throw_up('test '+ t + ' failed');
  ++t && (lingoLineMarkup('foo men foo', d).sanitize() === 'foo <s>men</s> foo') || throw_up('test '+ t + ' failed');
  ++t && (lingoLineMarkup('foo women foo', d).sanitize() === 'foo <s>women</s> foo') || throw_up('test '+ t + ' failed');
  ++t && (lingoLineMarkup('men men', d).sanitize() === '<s>men</s> <s>men</s>') || throw_up('test '+ t + ' failed');
  ++t && (lingoLineMarkup('men salarymen men men', d).sanitize() === '<s>men</s> salarymen <s>men</s> <s>men</s>') || throw_up('test '+ t + ' failed');
  ++t && (lingoLineMarkup('gentlespoons larks gents', d).sanitize() === '<s>gentlespoons</s> <u>larks</u> <s>gents</s>') || throw_up('test '+ t + ' failed');
  ++t && (lingoLineMarkup('g1 G1', d).sanitize() === '<s>g1</s> <s>G1</s>') || throw_up('test '+ t + ' failed');
  ++t && (lingoLineMarkup('LARKS', d).sanitize() === '<u>LARKS</u>') || throw_up('test '+ t + ' failed');
  ++t && (lingoLineMarkup("Rory O'More", d).sanitize() === "<u>Rory O'More</u>") || throw_up('test '+ t + ' failed');
  ++t && (lingoLineMarkup("rory o'more", d).sanitize() === "<u>rory o'more</u>") || throw_up('test '+ t + ' failed');
  return ''+t+' successful tests';
}

var bogusTerms = ['men', 'women', 'man', 'woman', 'gentlemen', 'gentleman', 'gents', 'gent', 'ladies', 'lady', 'leads', 'lead', 'follows', 'follow', 'larks', 'lark', 'ravens', 'raven',
                  'gypsy', 'yearn', "rory o'more", 'nn', 'n', 'p', 'l', 'g', 'm', 'w', 'n.', 'p.', 'l.', 'g.', 'm.', 'w.', 'g1', 'g2', 'l1', 'l2'];

var terms_for_uands;
// NB on return value: it is freshly allocated each time
function underlinesAndStrikes(dialect) {
  if (!terms_for_uands) {terms_for_uands = moves().concat(dancers());}
  var underlines = terms_for_uands.map(function(term) {return (dialect.dancers[term] || dialect.moves[term] || term).toLowerCase();});
  var strikes = terms_for_uands.concat(bogusTerms).filter(function(s) {return -1 === underlines.indexOf(s.toLowerCase());});
  return {underlines: underlines, strikes: strikes};
}

// ________________________________________________________________

function longestFirstSortFn(a,b) {
  return b.length - a.length;
};

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
