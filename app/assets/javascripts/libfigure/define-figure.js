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

function figureToString(f,prefs) {
  var fig_def = defined_events[f.move];
  if (fig_def) {
    var func = fig_def.props.stringify || figureGenericStringify;
    var main = func(f.move, f.parameter_values, prefs);
    var note = f.note;
    return note ? words(main,note) : main;
  }
  else if (f.move) {
    return "rogue figure '"+f.move+"'!";
  } else {
    return "empty figure";
  }
}

// Called if they don't specify a Stringify function in the figure definition:
function figureGenericStringify(move, parameter_values, prefs) {
  // todo: clean this up so it's not so obnoxiously ugly
  // it's thouroughly tested, so it will be safe to remove the fishing expeditions for who, balance and beats.
  var ps = parameters(move);
  var pstrings = parameter_strings(move, parameter_values, prefs);
  var acc = "";
  var subject_index = find_parameter_index_by_name("who", ps);
  var balance_index = find_parameter_index_by_name("bal", ps);
  var beats_index   = find_parameter_index_by_name("beats",ps);
  if (subject_index >= 0) { acc += pstrings[subject_index] + ' '; }
  if (balance_index >= 0) { acc += pstrings[balance_index] + ' '; }
  acc += preferredMove(move, prefs);
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

function parameter_strings(move, parameter_values, prefs) {
  if (!prefs) {throw_up('forgot prefs argument to parameter_strings');}
  // new! improved! catch null and undefined, and convert them to '____', without calling the individual parameter function
  var formal_parameters = parameters(move);
  var acc = [];
  for (var i=0; i<parameter_values.length; i++) {
    var pvi = parameter_values[i];
    var term;
    if ((pvi === undefined) || (pvi === null)) {
      term = '____';
    } else if (formal_parameters[i].string) {
      term = formal_parameters[i].string(pvi,move);
    } else {
      term = String(pvi);
    }
    acc.push(preferenceParameter(prefs,formal_parameters[i],term));
  }
  return acc;
}

// called when we don't know if the parameter is a dancer
function preferenceParameter(prefs, formal_parameter, actual_parameter) {
  var term = actual_parameter;
  if (formalParamIsDancers(formal_parameter) && (term in prefs.dancers)) {
    return prefs.dancers[term];
  } else {
    return term;
  }
}

// called when we do know the parameter is a dancer
function preferenceDancers(prefs, actual_parameter) {
  var term = actual_parameter;
  if (term in prefs.dancers) {
    return prefs.dancers[term];
  } else {
    return term;
  }
}

// === Teaching Names =============

function teachingName(move) {
  return teachingNames[move] || deAliasMove(move);
}

// teach this figure under its own name, not the name of it's root figure
function defineTeachingName(alias_move) {
  teachingNames[alias_move] = alias_move;
}

var teachingNames = {};

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
  defined_events[name] = {name: name, parameters: parameters, props: (props || {})};
}

function defineFigureAlias(newName, targetName, parameter_defaults) {
  "string" == typeof newName || throw_up("first argument isn't a string");
  "string" == typeof targetName || throw_up("second argument isn't a string");
  Array.isArray(parameter_defaults) || throw_up("third argument isn't an array aliasing "+newName);
  var target = defined_events[targetName] || 
        throw_up("undefined figure alias '"+newName +"' to '"+targetName+"'");
  if (target.parameters.length < parameter_defaults.length) {
    throw_up("oversupply of parameters to "+newName);
  }
  // defensively copy parameter_defaults[...]{...} into params
  var params = new Array(target.parameters.length);
  for (var i=0; i<target.parameters.length; i++) {
    params[i] = parameter_defaults[i] || target.parameters[i];
  }
  defined_events[newName] = {name: targetName, parameters: params, props: target.props};
}

function deAliasMove(move) {
    return defined_events[move].name;
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

// This (moves()) is basically no longer going to work.
// we need to return an array of {term: 'gyre', substitution: 'darcy'}
// and every consumer needs to be concious of the difference between move terms and move substitutions.
// We can eventually add movesTerms() if there is a demand for just that. 
function moves(optional_prefs) { // ditch optional_prefs and probably sorting too
  var ms = Object.keys(defined_events);
  if (optional_prefs) {
    ms = ms.map(function(move) { return preferredMove(move, optional_prefs); });
  }
  ms = ms.sort(function(a,b) {
    var aa = a.toLowerCase();
    var bb = b.toLowerCase();
    if (aa < bb) { return -1 ;}
    else if (aa > bb) { return 1; }
    else { return 0; }
  });
  return ms;
}

function movesMenuOrdering(prefs) {
  if (!prefs) {
    throw_up('must specify prefs to movesMenuOrdering');
  }
  var ms = moves();
  if (-1 === ms.slice(0,5).indexOf('swing')) { // swing not in first 5 entries
    ms.unshift('swing');                       // copy swing to front of the list
  }
  return ms.map(function (move) {return {value: move, label: preferredMove(move, prefs)};});
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

function is_progression(move) {
  var fig_def = defined_events[move];
  return fig_def && fig_def.props && fig_def.props.progression || false;
}

