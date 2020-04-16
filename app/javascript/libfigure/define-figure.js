//  ____  _____ _____ ___ _   _ _____      _____ ___ ____ _   _ ____  _____
// |  _ \| ____|  ___|_ _| \ | | ____|    |  ___|_ _/ ___| | | |  _ \| ____|
// | | | |  _| | |_   | ||  \| |  _| _____| |_   | | |  _| | | | |_) |  _|
// | |_| | |___|  _|  | || |\  | |__|_____|  _|  | | |_| | |_| |  _ <| |___
// |____/|_____|_|   |___|_| \_|_____|    |_|   |___\____|\___/|_| \_\_____|
//
// language construct for defining dance moves
// and related support functions for dealing with figures

import { libfigureObjectCopy, throw_up } from "./util"

// always freshly allocated
function newFigure(optional_progression) {
  var m = { move: "stand still", parameter_values: [8] }
  if (optional_progression) {
    m.progression = 1
  }
  return m
}

function figureBeats(f) {
  var defaultBeats = 8
  if (!f.move) return defaultBeats
  var idx = find_parameter_index_by_name("beats", parameters(f.move))
  return idx < 0 ? defaultBeats : f.parameter_values[idx]
}

function sumBeats(figures, optional_limit) {
  var acc = 0
  var n = Number.isInteger(optional_limit) ? optional_limit : figures.length
  for (var i = 0; i < n; i++) {
    acc += figureBeats(figures[i])
  }
  return acc
}

export const figureToHtml = (f, dialect) => {
  return figureFlatten(f, dialect, FLATTEN_FORMAT_HTML)
}

function figureToUnsafeText(f, dialect) {
  return figureFlatten(f, dialect, FLATTEN_FORMAT_UNSAFE_TEXT)
}

function figureToSafeText(f, dialect) {
  return figureFlatten(f, dialect, FLATTEN_FORMAT_SAFE_TEXT)
}

function figureFlatten(f, dialect, flatten_format) {
  var fig_def = defined_events[f.move]
  if (fig_def) {
    var func = fig_def.props.words || figureGenericWords
    var main = func(alias(f), f.parameter_values, dialect)
    var note = f.note
    var pilcrow = f.progression ? "⁋" : false
    if (note && note.trim()) {
      var fancy_note = lingoLineWords(stringInDialect(note, dialect), dialect)
      return words(main, fancy_note, pilcrow).flatten(flatten_format)
    } else {
      return words(main, pilcrow).flatten(flatten_format)
    }
  } else if (f.move) {
    return "undefined figure '" + words(f.move).flatten(flatten_format) + "'!"
  } else {
    return "empty figure"
  }
}

// Called if they don't specify a Words function in the figure definition:
function figureGenericWords(move, parameter_values, dialect) {
  var ps = parameters(move)
  var pwords = parameter_words(move, parameter_values, dialect)
  var acc = []
  var subject_index = find_parameter_index_by_name("who", ps)
  var balance_index = find_parameter_index_by_name("bal", ps)
  var beats_index = find_parameter_index_by_name("beats", ps)
  if (subject_index >= 0) {
    acc.push(pwords[subject_index])
  }
  if (balance_index >= 0) {
    acc.push(pwords[balance_index])
  }
  acc.push(moveSubstitution(move, dialect))
  ps.length == parameter_values.length ||
    throw_up(
      "parameter type mismatch. " +
        ps.length +
        " formals and " +
        parameter_values.length +
        " values"
    )
  for (var i = 0; i < parameter_values.length; i++) {
    if (i != subject_index && i != balance_index && i != beats_index) {
      acc.push(pwords[i])
    }
  }
  return new Words(acc)
}

function find_parameter_index_by_name(name, parameters) {
  var match_name_fn = function(p) {
    return p.name === name
  }
  return parameters.findIndex(match_name_fn, parameters)
}

// ================

function parameter_strings(move, parameter_values, dialect) {
  return parameter_strings_or_words(move, parameter_values, dialect, false)
}

function parameter_words(move, parameter_values, dialect) {
  return parameter_strings_or_words(move, parameter_values, dialect, true)
}

function parameter_strings_or_words(move, parameter_values, dialect, words_ok) {
  var formal_parameters = parameters(move)
  var acc = []
  for (var i = 0; i < parameter_values.length; i++) {
    var pvi = parameter_values[i]
    var term
    if (pvi === undefined || pvi === null) {
      term = "____"
    } else if (formal_parameters[i].words && words_ok) {
      // caller wants special html-enabled return type, and we support it, e.g. Custom
      term = formal_parameters[i].words(pvi, move, dialect)
    } else if (formal_parameters[i].string) {
      term = formal_parameters[i].string(pvi, move, dialect)
    } else {
      term = String(pvi)
    }
    acc.push(parameterSubstitution(formal_parameters[i], term, dialect))
  }
  return acc
}

// called when we don't know if the parameter is a dancer
function parameterSubstitution(formal_parameter, actual_parameter, dialect) {
  var term = actual_parameter
  return (
    (formalParamIsDancers(formal_parameter) && dialect.dancers[term]) ||
    actual_parameter
  )
}

// called when we do know the parameter is a dancer
function dancerSubstitution(dancer_term, dialect) {
  return dialect.dancers[dancer_term] || dancer_term
}

export const dancerMenuLabel = function(dancer_term, dialect) {
  if (dancer_term) {
    return dancerSubstitution(dancer_term, dialect)
  } else {
    return "unspecified"
  }
}

function heyLengthSubstitution(hey_length, dialect) {
  var hey_arr = parseHeyLength(hey_length)
  var hey0 = hey_arr[0]
  if (hey0 === "full" || hey0 === "half") {
    return hey0
  } else {
    hey_arr[1] === 1 ||
      hey_arr[1] === 2 ||
      throw_up("parseHeyLength()s second value is not 1 or 2: " + hey_arr[1])
    var nth_time = hey_arr[1] === 2 ? " 2nd time" : ""
    return dancerSubstitution(hey0, dialect) + " meet" + nth_time
  }
}

var moveSubstitutionPercentSRegexp = / *%S */g

function moveSubstitution(move_term, dialect) {
  var sub = moveSubstitutionWithEscape(move_term, dialect)
  return sub.replace(moveSubstitutionPercentSRegexp, " ").trim()
}

function moveSubstitutionWithEscape(move_term, dialect) {
  return dialect.moves[move_term] || move_term
}

// The basic applicaiton is a user substitution from 'form an ocean
// wave' to 'form a short wave' and makes it possible to extract the phrases
// 'a short wave' and 'short wave'.
//
// This takes a substitution that might be 'form a blahblah' and
// returns either 'a blahblah' or 'blahblah', depending on the
// optional add_article argument.
//
// Oh hey, the word 'form' and the word 'a' are both entered by the
// user, and so are optional.
// Check the specs for lots of examples.
function moveSubstitutionWithoutForm(
  move_term,
  dialect,
  add_article,
  adjectives
) {
  if (undefined === add_article) {
    add_article = false
  }
  if (undefined === adjectives) {
    adjectives = false
  }
  var subst = moveSubstitution(move_term, dialect)
  var match = subst.match(/(?:form )?(?:(an?) )?(.*)/i)
  var root = match[2]
  var adjectives_and_root = words(adjectives, root)
  if (add_article) {
    var article = /[aeiou]/.test(adjectives_and_root.peek()) ? "an" : "a"
    return words(article, adjectives, root)
  } else {
    return adjectives_and_root
  }
}

// === Related Moves =============
// Note that a lot of these are 'is composed of' relationships, and as such they
// might be moved to another representation later.

var _relatedMoves = {}

function defineRelatedMove1Way(from, to) {
  _relatedMoves[from] = _relatedMoves[from] || []
  _relatedMoves[from].push(to)
}

export const defineRelatedMove2Way = (from, to) => {
  defineRelatedMove1Way(from, to)
  defineRelatedMove1Way(to, from)
}

function relatedMoves(move) {
  return _relatedMoves[move] || []
}

var defined_events = {}

////////////////////////////////////////////////
// defineFigure                               //
////////////////////////////////////////////////

export const defineFigure = (name, parameters, props) => {
  var props2 = libfigureObjectCopy(props || {})
  if (!props2.goodBeats) {
    var beats_index = find_parameter_index_by_name("beats", parameters)
    var beats_default = beats_index >= 0 && parameters[beats_index].value
    if (beats_default || beats_default === 0) {
      props2.goodBeats = goodBeatsEqualFn(beats_default)
    }
  }
  defined_events[name] = { name: name, parameters: parameters, props: props2 }
}

export const defineFigureAlias = (
  alias_name,
  canonical_name,
  parameter_defaults
) => {
  "string" == typeof alias_name || throw_up("first argument isn't a string")
  "string" == typeof canonical_name ||
    throw_up("second argument isn't a string")
  Array.isArray(parameter_defaults) ||
    throw_up("third argument isn't an array aliasing " + alias_name)
  var target =
    defined_events[canonical_name] ||
    throw_up(
      "undefined figure alias '" + alias_name + "' to '" + canonical_name + "'"
    )
  if (target.parameters.length !== parameter_defaults.length) {
    throw_up("wrong number of parameters to " + alias_name)
  }
  // defensively copy parameter_defaults[...]{...} into params
  var params = new Array(target.parameters.length)
  for (var i = 0; i < target.parameters.length; i++) {
    params[i] = parameter_defaults[i] || target.parameters[i]
  }
  defined_events[alias_name] = {
    name: canonical_name,
    parameters: params,
    alias_parameters: parameter_defaults,
    props: target.props,
  }
}

export const deAliasMove = function(move) {
  return defined_events[move].name
}

export const isAlias = function(move_string) {
  return defined_events[move_string].name !== move_string
}

// you can also use 'figure.move' in js - this is a late addition because we need a function -dm 04-20-2018
function move(figure) {
  return figure.move
}

function alias(figure) {
  var fn = moveProp(figure.move, "alias", move)
  return fn(figure)
}

// does not include itself
function aliases(move) {
  // loop through defined_events, returning all keys where value.name == move
  var acc = []
  Object.keys(defined_events).forEach(function(key) {
    var value = defined_events[key]
    if (value.name == move && key != move) {
      acc.push(key)
    }
  })
  return acc
}

export const aliasFilter = function(move_alias_string) {
  if (move_alias_string === deAliasMove(move_alias_string)) {
    throw_up(
      "aliasFilter(someDeAliasedMove) would produce weirdly overly specific filters if we weren't raising this error - it's only defined for move aliases"
    )
  }
  return aliasParameters(move_alias_string).map(function(param) {
    return param ? param.value : "*"
  })
}

// List all the moves known to contradb.
// See also: moveTermsAndSubstitutions
export const moves = () => {
  return Object.keys(defined_events)
}

function moveTermsAndSubstitutions(dialect) {
  if (!dialect) {
    throw_up("must specify dialect to moveTermsAndSubstitutions")
  }
  var terms = Object.keys(defined_events)
  var ms = terms.map(function(term) {
    return { term: term, substitution: moveSubstitution(term, dialect) }
  })
  ms = ms.sort(function(a, b) {
    var aa = a.substitution.toLowerCase()
    var bb = b.substitution.toLowerCase()
    if (aa < bb) {
      return -1
    } else if (aa > bb) {
      return 1
    } else {
      return 0
    }
  })
  return ms
}

export const moveTermsAndSubstitutionsForSelectMenu = dialect => {
  if (!dialect) {
    throw_up("must specify dialect to moveTermsAndSubstitutionsForSelectMenu")
  }
  var mtas = moveTermsAndSubstitutions(dialect)
  var swing_index = mtas.findIndex(function(e) {
    return "swing" === e.term
  })
  if (swing_index >= 5) {
    mtas.unshift(mtas[swing_index]) // copy swing to front of the list
  }
  return mtas
}

function isMove(string) {
  return !!defined_events[string]
}

export const parameterLabel = (move, index) => {
  var fig_def = defined_events[move]
  var ps = parameters(move)
  return (
    (fig_def &&
      fig_def.props &&
      fig_def.props.labels &&
      fig_def.props.labels[index]) ||
    (ps[index] && ps[index].name)
  )
}

var issued_parameter_warning = false

// TODO: complete renaming to formalParameters
export const parameters = move => {
  var fig = defined_events[move]
  if (fig) {
    return fig.parameters
  }
  if (move && !issued_parameter_warning) {
    issued_parameter_warning = true
    throw_up("could not find a figure definition for '" + move + "'. ")
  }
  return []
}

export const formalParameters = parameters

function aliasParameters(move) {
  var fig = defined_events[move]
  if (fig && fig.alias_parameters) {
    return fig.alias_parameters
  } else {
    throw_up(
      "call to aliasParameters('" +
        move +
        "') on a thing that doesn't seem to be an alias"
    )
  }
}

function moveProp(move_or_nil, property_name, default_value) {
  if (move_or_nil) {
    var fig_def = defined_events[move_or_nil]
    return (fig_def && fig_def.props[property_name]) || default_value
  } else {
    return default_value
  }
}

function stringInDialect(str, dialect) {
  if (textInDialect(dialect)) {
    return str
  } else {
    // Since this is called a lot, performance might be helped by memoizing dialectRegExp(dialect)
    return str.replace(dialectRegExp(dialect), function(
      _whole_match,
      left_whitespace,
      match
    ) {
      // conceptually this is a pretty straightforward lookup in one hash or another, and usually that's all it takes...
      var substitution = dialect.moves[match] || dialect.dancers[match]
      if (substitution) {
        return stringInDialectHelper(
          match,
          substitution,
          left_whitespace,
          match
        )
      }
      // ...but sometimes they've uppercased their text, so we've gotta look again in the hash (in lower case)...
      var match_lower = match.toLowerCase()
      substitution = dialect.moves[match_lower] || dialect.dancers[match_lower]
      if (substitution) {
        return stringInDialectHelper(
          match_lower,
          substitution,
          left_whitespace,
          match
        )
      }
      // ...and sometimes the term itself is in mixed case, e.g. 'California twirl' or "Rory O'More"...
      var term
      for (term in dialect.moves) {
        if (term.toLowerCase() === match_lower) {
          return stringInDialectHelper(
            term,
            dialect.moves[term],
            left_whitespace,
            match
          )
        }
      }
      for (term in dialect.dancers) {
        if (term.toLowerCase() === match_lower) {
          return stringInDialectHelper(
            term,
            dialect.dancers[term],
            left_whitespace,
            match
          )
        }
      }
      /// ... I guess it's possible none of this worked, which is weird enough to explode.
      throw_up("failed to look up " + match)
    })
  }
}

// polish the case and remove %S in the final substitution
function stringInDialectHelper(term, substitution, left_whitespace, match) {
  var s
  if (hasUpperCase(substitution)) {
    s = substitution
  } else if (moreCapitalizedThan(match, term)) {
    s = capitalize(substitution)
  } else {
    s = substitution
  }
  return left_whitespace + s.replace(/%S/g, "")
}

function hasUpperCase(x) {
  return x !== x.toLowerCase()
}

function moreCapitalizedThan(left, right) {
  return hasUpperCase(left) && !hasUpperCase(right)
}

// Return a new string with the first lower case letter (if any) capitalized
function capitalize(s) {
  // ugh, unicode is hard in JS
  for (var i = 0; i < s.length; i++) {
    var c = s[i]
    var c_big = c.toUpperCase()
    if (c_big !== c) {
      var x = s.split("")
      x.splice(i, 1, c_big)
      return x.join("")
    }
  }
  return s
}

function dialectRegExp(dialect) {
  var move_strings = Object.keys(dialect.moves)
  var dance_strings = Object.keys(dialect.dancers)
  var term_strings = move_strings.concat(dance_strings).sort(longestFirstSortFn)
  var big_re_string_center = term_strings.map(regExpEscape).join("|")
  var big_re_string
  if (big_re_string_center) {
    big_re_string =
      "(\\s|" +
      PUNCTUATION_CHARSET_STRING +
      "|^)(" +
      big_re_string_center +
      ")(?=\\s|" +
      PUNCTUATION_CHARSET_STRING +
      "|$)"
  } else {
    big_re_string = "^[]" // unmatchable regexp - https://stackoverflow.com/a/25315586/5158597
  }
  return new RegExp(big_re_string, "gi")
}

////

function goodBeatsWithContext(figures, index) {
  var figure = figures[index]
  if (
    0 !==
    sumBeats(figures, index + 1) % moveProp(figure.move, "alignBeatsEnd", 1)
  ) {
    return false
  } else {
    return goodBeats(figure)
  }
}

function goodBeats(figure) {
  var fn = moveProp(figure.move, "goodBeats", defaultGoodBeats)
  return fn(figure)
}

export const goodBeatsMinMaxFn = (min, max) => {
  return function(figure) {
    var beats = figureBeats(figure)
    return min <= beats && beats <= max
  }
}

export const goodBeatsMinFn = min => {
  return function(figure) {
    var beats = figureBeats(figure)
    return min <= beats
  }
}

export const goodBeatsEqualFn = beats => {
  return function(figure) {
    return beats === figureBeats(figure)
  }
}

export const defaultGoodBeats = goodBeatsEqualFn(8)
