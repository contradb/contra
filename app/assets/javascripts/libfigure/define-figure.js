//  ____  _____ _____ ___ _   _ _____      _____ ___ ____ _   _ ____  _____ 
// |  _ \| ____|  ___|_ _| \ | | ____|    |  ___|_ _/ ___| | | |  _ \| ____|
// | | | |  _| | |_   | ||  \| |  _| _____| |_   | | |  _| | | | |_) |  _|  
// | |_| | |___|  _|  | || |\  | |__|_____|  _|  | | |_| | |_| |  _ <| |___ 
// |____/|_____|_|   |___|_| \_|_____|    |_|   |___\____|\___/|_| \_\_____|
//
// language construct for defining dance moves
// and related support functions for dealing with figures

// always freshly allocated
function newFigure () {
  return { parameter_values: [] };
}

function figureBeats (f) {
  var defaultBeats = 8;
  if (! f.move) return defaultBeats;
  var idx = find_parameter_index_by_name("beats", parameters(f.move));
  return (idx<0) ? defaultBeats : f.parameter_values[idx];
}

function sumBeats(figures,optional_limit) {
  var acc = 0;
  var n = isInteger(optional_limit) ? optional_limit : figures.length;
  for (var i = 0; i < n; i++) {
    acc += figureBeats(figures[i]);
  }
  return acc;
}

function figureToString(f,dialect) {
  var fig_def = defined_events[f.move];
  if (fig_def) {
    var func = fig_def.props.stringify || figureGenericStringify;
    var main = func(alias(f), f.parameter_values, dialect);
    var note = f.note;
    return note ? words(main,stringInDialect(note, dialect)) : main;
  } else if (f.move) {
    return "rogue figure '"+f.move+"'!";
  } else {
    return "empty figure";
  }
}

// Called if they don't specify a Stringify function in the figure definition:
function figureGenericStringify(move, parameter_values, dialect) {
  // todo: clean this up so it's not so obnoxiously ugly
  // it's thouroughly tested, so it will be safe to remove the fishing expeditions for who, balance and beats.
  var ps = parameters(move);
  var pstrings = parameter_strings(move, parameter_values, dialect);
  var acc = "";
  var subject_index = find_parameter_index_by_name("who", ps);
  var balance_index = find_parameter_index_by_name("bal", ps);
  var beats_index   = find_parameter_index_by_name("beats",ps);
  if (subject_index >= 0) { acc += pstrings[subject_index] + ' '; }
  if (balance_index >= 0) { acc += pstrings[balance_index] + ' '; }
  acc += moveSubstitution(move, dialect);
  ps.length == parameter_values.length || throw_up("parameter type mismatch. "+ps.length+" formals and "+parameter_values.length+" values");
  for (var i=0; i < parameter_values.length; i++) {
    if ((i != subject_index) && (i != balance_index) && (i != beats_index)) {
      acc += ' ' + pstrings[i];
    }
  }
  if (is_progression(move)) {
    acc += ' ' + progressionString;
  }
  if ((beats_index >= 0) && (parameter_values[beats_index].value != ps[beats_index].value)) {
    acc +=  ' ' + pstrings[beats_index];
  }
  return acc;
}

function find_parameter_index_by_name(name, parameters) {
  var match_name_fn = function(p) {return p.name === name;};
  return parameters.findIndex(match_name_fn, parameters);
}

var progressionString = "to new neighbors";

// ================

function parameter_strings(move, parameter_values, dialect) {
  if (!dialect) {throw_up('forgot dialect argument to parameter_strings');}
  var formal_parameters = parameters(move);
  var acc = [];
  for (var i=0; i<parameter_values.length; i++) {
    var pvi = parameter_values[i];
    var term;
    if ((pvi === undefined) || (pvi === null)) {
      term = '____';
    } else if (formal_parameters[i].string) {
      term = formal_parameters[i].string(pvi, move, dialect);
    } else {
      term = String(pvi);
    }
    acc.push(parameterSubstitution(formal_parameters[i], term, dialect));
  }
  return acc;
}

// called when we don't know if the parameter is a dancer
function parameterSubstitution(formal_parameter, actual_parameter, dialect) {
  var term = actual_parameter;
  return (formalParamIsDancers(formal_parameter) && dialect.dancers[term]) || actual_parameter;
}

// called when we do know the parameter is a dancer
function dancerSubstitution(dancer_term, dialect) {
  return dialect.dancers[dancer_term] || dancer_term;
}

function moveSubstitution(move_term, dialect) {
  return dialect.moves[move_term] || move_term;
}

// === Related Moves =============
// Note that a lot of these are 'is composed of' relationships, and as such they
// might be moved to another representation later.

var _relatedMoves = {};

function defineRelatedMove1Way(from, to) {
  _relatedMoves[from] = _relatedMoves[from] || [];
  _relatedMoves[from].push(to);
}

function defineRelatedMove2Way(from, to) {
  defineRelatedMove1Way(from, to);
  defineRelatedMove1Way(to, from);
}

function relatedMoves(move) {
  return _relatedMoves[move] || [];
}

var defined_events = {};

////////////////////////////////////////////////
// defineFigure                               //
////////////////////////////////////////////////

function defineFigure(name, parameters, props) {
  var props2 = libfigureObjectCopy(props || {});
  if (!props2.goodBeats) {
    var beats_index = find_parameter_index_by_name("beats",parameters);
    var beats_default = parameters[beats_index].value;
    if (beats_default !== undefined) {
      props2.goodBeats = goodBeatsEqualFn(beats_default);
    }
  }
  defined_events[name] = {name: name, parameters: parameters, props: props2};
}

function defineFigureAlias(alias_name, canonical_name, parameter_defaults) {
  "string" == typeof alias_name || throw_up("first argument isn't a string");
  "string" == typeof canonical_name || throw_up("second argument isn't a string");
  Array.isArray(parameter_defaults) || throw_up("third argument isn't an array aliasing "+alias_name);
  var target = defined_events[canonical_name] ||
        throw_up("undefined figure alias '"+alias_name +"' to '"+canonical_name+"'");
  if (target.parameters.length !== parameter_defaults.length) {
    throw_up("wrong number of parameters to "+alias_name);
  }
  // defensively copy parameter_defaults[...]{...} into params
  var params = new Array(target.parameters.length);
  for (var i=0; i<target.parameters.length; i++) {
    params[i] = parameter_defaults[i] || target.parameters[i];
  }
  defined_events[alias_name] = {name: canonical_name, parameters: params, alias_parameters: parameter_defaults,  props: target.props};
}

function deAliasMove(move) {
    return defined_events[move].name;
}

function isAlias(move_string) {
  return defined_events[move_string].name !== move_string;
}

// you can also use 'figure.move' in js - this is a late addition because we need a function -dm 04-20-2018
function move(figure) {
  return figure.move;
};

function alias(figure) {
  var fn = moveProp(figure.move, 'alias', move);
  return fn(figure);
}

// does not include itself
function aliases(move) {
  // loop through defined_events, returning all keys where value.name == move
  var acc = [];
  Object.keys(defined_events).forEach(function(key) {
    var value = defined_events[key];
    if (value.name == move && key != move) {
      acc.push(key);
    }
  });
  return acc;
}

function aliasFilter(move_alias_string) {
  if (move_alias_string === deAliasMove(move_alias_string)) {
    throw_up("aliasFilter(someDeAliasedMove) would produce weirdly overly specific filters if we weren't raising this error - it's only defined for move aliases");
  }
  return aliasParameters(move_alias_string).map(function(param) {
    return param ? param.value : '*';
  });
}

// List all the moves known to contradb.
// See also: moveTermsAndSubstitutions
function moves() {
  return Object.keys(defined_events);
}

function moveTermsAndSubstitutions(dialect) {
  if (!dialect) { throw_up('must specify dialect to moveTermsAndSubstitutions'); }
  var terms = Object.keys(defined_events);
  var ms = terms.map(function(term) { return {term: term, substitution: moveSubstitution(term, dialect)}; });
  ms = ms.sort(function(a,b) {
    var aa = a.substitution.toLowerCase();
    var bb = b.substitution.toLowerCase();
    if (aa < bb) { return -1 ;}
    else if (aa > bb) { return 1; }
    else { return 0; }
  });
  return ms;
}

function moveTermsAndSubstitutionsForSelectMenu(dialect) {
  if (!dialect) { throw_up('must specify dialect to moveTermsAndSubstitutionsForSelectMenu'); }
  var mtas = moveTermsAndSubstitutions(dialect);
  var swing_index = mtas.findIndex(function (e) { return 'swing' === e.term;});
  if (swing_index >= 5) {
    mtas.unshift(mtas[swing_index]);                       // copy swing to front of the list
  }
  return mtas;
}

function isMove(string) {
  return !!defined_events[string];
}

var issued_parameter_warning = false;

// consider renaming to formalParameters
function parameters(move){
  var fig = defined_events[move];
  if (fig) {
    return fig.parameters;
  }
  if (move && !issued_parameter_warning) {
    issued_parameter_warning = true;
    throw_up("could not find a figure definition for '"+move+"'. ");
  }
  return [];
}

function aliasParameters(move){
  var fig = defined_events[move];
  if (fig && fig.alias_parameters) {
    return fig.alias_parameters;
  } else {
    throw_up("call to aliasParameters('"+move+"') on a thing that doesn't seem to be an alias");
  }
}

function moveProp(move_or_nil, property_name, default_value) {
  if (move_or_nil) {
    var fig_def = defined_events[move_or_nil];
    return fig_def && fig_def.props[property_name] || default_value;
  } else {
    return default_value;
  }
}

function is_progression(move) {
  // var fig_def = defined_events[move];
  // return fig_def && fig_def.props && fig_def.props.progression || false;
  return moveProp(move, 'progression', false);
}

function stringInDialect(str, dialect) {
  // Since this is called a lot, performance might be helped by memoizing dialectRegExp(dialect)
  return str.replace(dialectRegExp(dialect), function (match) {
    return dialect.moves[match] || dialect.dancers[match];
  });
}

function dialectRegExp(dialect) {
  var move_strings = Object.keys(dialect.moves).map(regExpEscape);
  var dance_strings = Object.keys(dialect.dancers).map(regExpEscape);
  var unmatchable_re_string = '^[]'; // https://stackoverflow.com/a/25315586/5158597
  var big_re_string = move_strings.concat(dance_strings).map(parenthesize).join('|') || unmatchable_re_string;
  return new RegExp(big_re_string, 'g');
}

function parenthesize(term) {
  return '('+term+')';
}

////

function goodBeatsWithContext(figures, index) {
  var figure = figures[index];
  if (0 !== sumBeats(figures,index+1) % moveProp(figure.move, 'alignBeatsEnd', 1)) {
    return false;
  } else {
    return goodBeats(figure);
  }
}

function goodBeats(figure) {
  var fn = moveProp(figure.move, 'goodBeats', defaultGoodBeats);
  return fn(figure);
}

function goodBeatsMinMaxFn(min, max) {
  return function(figure) {
    var beats = figureBeats(figure);
    return (min <= beats) && (beats <= max);
  };
}

function goodBeatsEqualFn(beats) {
  return function(figure) {
    return beats === figureBeats(figure);
  };
}

var defaultGoodBeats = goodBeatsEqualFn(8);
