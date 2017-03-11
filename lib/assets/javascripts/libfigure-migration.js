// a JSON-to-JSON translater used by a migration

function originalToJSLibFigure(figures) {
  return figures.map(originalToJSLibFigure1);
}

function originalToJSLibFigure1(figure) {
  var move_name_baggage = unpackMoveName(figure)
  var move = move_name_baggage['move']
  var params = parameters(move);
  var get_parameter_values = function (param) {
    if (param.name === 'who') {
      return translateWho(figure.who);
    } else if (param.name === 'whom') {
      return move_name_baggage.whom;
    } else if (param.name === 'beats') {
      return figure.beats;
    } else if (param.name === 'bal') {
      return figure.balance || false;
    } else if (param.name === 'hand') {
      return oldMoveIsClockwise(figure.move);
    } else if (param.name === 'circling' || param.name === 'places') {
      return figure.degrees;
    } else if (param.name === 'turn' || param.name === 'shoulder') {
      return move_name_baggage[param.name]
    } else if (param.name === 'facing') {
      return 'forward';         // all old down_the_halls/up_the_halls were this way, barring notes to the contray
    } else if (param.name === 'slide') {
      return move_name_baggage.slide;
    } else if (param.name === '½sash') {
      return move_name_baggage['½sash'];
    } else if (param.name === 'grip') {
      return undefined;
    } else if (param.name === 'custom') {
      return figure.notes || '';
    } else {
      throw_up("param name '"+param.name+"' missing from originalToJSLibFigure");
    }
  };
  var h = {parameter_values: params.map(get_parameter_values), move: move};
  var figure_has_no_custom_text_parameters = (-1 === params.findIndex(function(param) { return param.name == 'custom';}));
  if (figure.notes && figure_has_no_custom_text_parameters) { h.note = figure.notes; }
  if (figure.formation && (figure.formation !== 'square')) {
    h.note = (h.note || '') +
      ' from ' + figure.formation.replace(/_/g, ' '); // if altering this line, also change _formation_note_regexp
  }
  return h;
}

var _unpack_move_name = {
  allemande_left: 'allemande',
  allemande_right: 'allemande',
  circle_left: 'circle',
  circle_right: 'circle',
  gyre_left_shoulder: 'gyre',
  gyre_right_shoulder: 'gyre',
  star_left: 'star',
  star_right: 'star',
  slide_left_rory_o_moore: "Rory O'Moore",
  slide_right_rory_o_moore: "Rory O'Moore",
  pull_by_left: 'pull by',
  pull_by_right: 'pull by',
  to_ocean_wave: 'ocean wave',
  roll_away_half_sashay_partner:  'roll away',
  roll_away_half_sashay_neighbor: 'roll away',
  roll_away_partner:  'roll away',
  roll_away_neighbor: 'roll away',
  half_a_hey: 'half hey'
}
function unpackMoveName(oldFigure) {
  var oldMove = oldFigure.move.toLowerCase();
  if (oldMove === 'custom' && (oldFigure.balance || (oldFigure.who !== 'everybody'))) {
    return { move: 'custom yucky' };
  }
  var h = {move: _unpack_move_name[oldMove] || oldMove.replace(/_/g, ' ')}
  var oldMove_ends_in_left = oldMove.match(/_left((_shoulder)|(_rory_o_moore))?$/);
  var oldMove_ends_in_right = oldMove.match(/_right((_shoulder)|(_rory_o_moore))?$/);
  if (oldMove_ends_in_left)  { h.turn = h.slide = true;  h.shoulder = false; }
  if (oldMove_ends_in_right) { h.turn = h.slide = false; h.shoulder = true; }
  var oldMove_ends_in_partner = oldMove.match(/_partner$/);
  var oldMove_ends_in_neighbor = oldMove.match(/_neighbor$/);
  if (oldMove_ends_in_partner) { h.whom = 'partner'; }
  if (oldMove_ends_in_neighbor) { h.whom = 'neighbor'; }
  var oldMove_has_half_sashay = oldMove.match(/_half_sashay/);
  if (oldMove_has_half_sashay) { h['½sash'] = true; }
  return h;
}

var _translate_who = {neighbor: 'neighbors',
                      partner: 'partners',
                      everybody: 'everyone'};

function translateWho(oldWho) {
  return _translate_who[oldWho] || oldWho;
}
function untranslateWho(lfWho) {
  // hash table: ur doing it wrong :D
  for(var oldWho in _translate_who){
    if(_translate_who[oldWho]==lfWho) {
      return oldWho;
    }
  }
  return lfWho;
}

var _old_move_is_clockwise = {
  box_the_gnat: true,
  swat_the_flea: false,
  circle_left: true,
  circle_right: false,
  allemande_left: false,
  allemande_right: true,
  pull_by_right: true,
  pull_by_left: false,
  star_left: false,
  star_right: true,
  star_promenade: false
}

function oldMoveIsClockwise(oldMove) {
  var cw = _old_move_is_clockwise[oldMove];
  if (cw === true || cw === false) {
    return cw;
  } else {
    throw_up("move '"+oldMove+"' missing from oldMoveIsClockwise table");
  }
}

////////////////////////////////////////////////////////////////
// reverse migrator                                           //
////////////////////////////////////////////////////////////////
function jsLibFigureToOriginal(figures) {
  return figures.map(jsLibFigureToOriginal1);
}

function jsLibFigureToOriginal1(figure) {
  var lf_move = figure.move;
  var param_vals = figure.parameter_values;
  var params = parameters(lf_move);
  var h = { who: extractWho(params, param_vals),
            move: findOldMove(figure),
            beats: extractBeats(params, param_vals),
            formation: parseFormationFromNote(figure.note)
          };
  var degrees = extractDegrees(params, param_vals);
  if (degrees) { h.degrees = degrees; }
  if (extractBal(params, param_vals)) { h.balance = true; }
  var custom_text = extractCustomText(params, param_vals);
  var restored_note = custom_text + (figure.note ? dropFormationSuffixFromNote(figure.note).trim() : '');
  if (restored_note !== '') { h.notes = restored_note; }
  return h;
}

function extractDegrees(params, param_vals) {
  var index = find_parameter_index_by_name('circling', params);
  if (index < 0) {
    index = find_parameter_index_by_name('places', params);
  }
  return (index >= 0) && param_vals[index];
}

function extractCustomText(params, param_vals) {
  var index = find_parameter_index_by_name('custom', params);
  return (index >= 0) ? param_vals[index] : '';
}

function extractWho(params, param_vals) {
  var index = find_parameter_index_by_name('who', params);
  if (index >= 0) {
    return untranslateWho(param_vals[index]);
  } else {
    return 'everybody';
  }
}
function extractBeats(params, param_vals) {
  var index = find_parameter_index_by_name('beats', params);
  if (index >= 0) {
    return param_vals[index];
  } else {
    throw_up('No beats, should I really return 0?'); // I'm okay with it.
    return 0;
  }
}
function extractBal(params, param_vals) {
  var index = find_parameter_index_by_name('bal', params);
  return (index >= 0) && param_vals[index];
}

function findOldMove(lf_figure) {
  var lf_move = lf_figure.move;
  var param_vals = lf_figure.parameter_values;
  var params = parameters(lf_move);
  var underscore_lf_move = lf_move.replace(/ /g,'_')
  if (oldAtomicMoves[underscore_lf_move]) {
    return underscore_lf_move;
  } else if (underscore_lf_move === 'half_hey') {
    return 'half_a_hey';
  } else if (underscore_lf_move === 'custom_yucky') {
    return 'custom';
  } else if (underscore_lf_move === 'ocean_wave') {
    return 'to_ocean_wave';
  } else if (underscore_lf_move === 'roll_away') {
    whom = param_vals[find_parameter_index_by_name('whom', params)]
    sashay = param_vals[find_parameter_index_by_name('½sash', params)]
    return 'roll_away_'+(sashay?'half_sashay_':'')+whom;
  } else if (oldLeftRightMoves[underscore_lf_move]) {
    var              index = find_parameter_index_by_name('turn', params);
    if (index < 0) { index = find_parameter_index_by_name('hand', params); }
    if (index < 0) { index = find_parameter_index_by_name('shoulder', params); }
    if (index < 0) { index = find_parameter_index_by_name('slide', params); }
    if (index < 0) { throw_up('can not find a turn, hand, shoulder, or slide for '+lf_move); }
    return oldLeftRightMoves[underscore_lf_move][param_vals[index] ? 0 : 1];
  } else {
    throw_up('can not findOldMove for '+lf_move);
  }
}



var oldLeftRightMoves = {
  allemande: ['allemande_right', 'allemande_left'],
  circle: ['circle_left', 'circle_right'],
  gyre: ['gyre_right_shoulder', 'gyre_left_shoulder'],
  star: ['star_right', 'star_left'],
  pull_by: ['pull_by_right', 'pull_by_left'],
  star_promenade: ['did_not_support_right_handed_star_promenades','star_promenade'],
  "Rory_O'Moore": ['slide_left_rory_o_moore', 'slide_right_rory_o_moore']
  // unused: (maybe I screwed up and should put stuff here?)
  // gyre_star_ccw_gentlespoons_backing: true,
  // gyre_star_ccw_ladles_backing: true,
  // gyre_star_clockwise_gentlespoons_backing: true,
  // gyre_star_clockwise_ladles_backing: true,

  // roll_away_half_sashay_neighbor: true,
  // roll_away_half_sashay_partner: true,
  // roll_away_neighbor: true,
  // roll_away_partner: true,
};

var oldAtomicMoves = {
  allemande_and_orbit: true,
  arizona_twirl: true,
  balance: true,
  balance_the_ring: true,
  box_circulate: true,
  box_the_gnat: true,
  butterfly_whirl: true,
  california_twirl: true,
  chain: true,
  cross_trails: true,
  custom: true,
  do_si_do: true,
  down_the_hall: true,
  half_a_hey: true,
  hey: true,
  long_lines: true,
  mad_robin: true,
  petronella: true,
  promenade_across: true,
  right_left_through: true,
  see_saw: true,
  star_promenade: true,
  swat_the_flea: true,
  swing: true,
  to_long_wavy_line: true,
  to_ocean_wave: true,
  up_the_hall: true
}

var _formation_note_regexp = /from (short lines|short wavy lines|long wavy lines|long wavy line|custom)$/

function parseFormationFromNote(note) {
  if (!note) { return 'square'; }
  var r = note.match(_formation_note_regexp);
  if (r) {
    return r[1].replace(/ /g, '_');
  } else {
    return 'square';
  }
}

function dropFormationSuffixFromNote(note) {
  if (!note) { return note; }
  var r = note.match(_formation_note_regexp);
  if (r) {
    return note.slice(0, note.length - r[0].length);
  } else {
    return note;
  }
}


function testConverters(figures) {
  return figures.map(function(figure) {
    var retranslated_figure = jsLibFigureToOriginal1(originalToJSLibFigure1(figure));
    return [figure, retranslated_figure];
  });
}
