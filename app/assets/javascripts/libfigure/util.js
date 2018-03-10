function set_if_unset (dict, key, value) {
    if (!(key in dict))
        dict[key] = value;
}

// take words, put them in strings, return a big, space separated string of them all. 
function words() {
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

var defaultDialect = {moves: {},
                 dancers: {}};

var testDialect = {moves: {gyre: 'darcy',
                         allemande: 'almond',
                         'see saw': 'do si do left shoulder',
                         'ocean wave': 'mush into short wavy lines'},
                 dancers: {ladles: 'ravens',
                           gentlespoons: 'larks'}};

/*
defaultDialect = {moves: {gyre: 'darcy',
                     'meltdown swing': 'gyre meltdown',
                     allemande: 'almond',
                     'see saw': 'do si do left shoulder',
                     'ocean wave': 'mush into short wavy lines',
                     chain: 'cavort'},
             dancers: {ladles: 'ravens',
                       gentlespoons: 'larks',
                       shadows: 'demipartners'}};
*/
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

function moveSubstitution(move_term, dialect) {
  return dialect.moves[move_term] || move_term;
}

// see also the similar ruby-side function slugify_move 
// TODO: unify the two, and enforce that the slug/deslug mapping is 1-1 in tests
function slugifyTerm(term) {
  return term.toLowerCase().replace('&', 'and').replace(' ', '-').replace(/[^a-z0-9-]/, '');
}

// ________________________________________________________________
