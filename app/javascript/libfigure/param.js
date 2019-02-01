//     ____   _    ____      _    __  __
//    |  _ \ / \  |  _ \    / \  |  \/  |
//    | |_) / _ \ | |_) |  / _ \ | |\/| |
//    |  __/ ___ \|  _ <  / ___ \| |  | |
//    |_| /_/   \_\_| \_\/_/   \_\_|  |_|
//
// Params have semantic value specific to each figure.
// Though some patterns have emerged. Patterns like:
// figures have a subject telling who's acted on by the figure.
//

import { throw_up } from './util';

const __params = {};

function defineParam(codeName, hash) {
  __params[codeName] = hash;
}

export const param = (codeName) => {
  return __params[codeName] || throw_up('attempt to find non param: '+codeName);
}


function stringParamBalance (value) {
  if (value === '*') {
    return 'optional balance & ';
  } else if (value) {
    return 'balance & ';
  } else return '';
}

defineParam('balance_true',   {name: "bal", value: true,  ui: chooser_boolean, string: stringParamBalance});
defineParam('balance_false',  {name: "bal", value: false, ui: chooser_boolean, string: stringParamBalance});
// if we ever add just an undefaulted 'balance', we probably should add it to the thing that adds
// related moves in after-figure.js -dm 01-13-2019

defineParam('swing_prefix_none',      {name: "prefix", value: "none",      ui: chooser_swing_prefix});
defineParam('swing_prefix_meltdown',  {name: "prefix", value: "meltdown",  ui: chooser_swing_prefix});

function stringParamHalfSashay (value) {
  if (value === '*') {
    return 'maybe with a half sashay';
  } else if (value) {
    return 'with a half sashay';
  } else return '';
}
// param_half_sashay_true  = {name: "½sash", value: true,  ui: chooser_boolean, string: stringParamHalfSashay} not used
defineParam('half_sashay_false',  {name: "½sash", value: false, ui: chooser_boolean, string: stringParamHalfSashay});

defineParam('subject_walk_in_true',  {name: "in", value: true, ui: chooser_boolean});
defineParam('others_walk_out_false',  {name: "out", value: false, ui: chooser_boolean});
defineParam('pass_through_true',  {name: "pass thru", value: true, ui: chooser_boolean});

// angular is picky about duped addresses of params, so we give them unique addresses.
// if we move to another framework, these can all be compressed
defineParam('ricochet1_false',  {name: "rico", value: false, ui: chooser_boolean});
defineParam('ricochet2_false',  {name: "rico", value: false, ui: chooser_boolean});
defineParam('ricochet3_false',  {name: "rico", value: false, ui: chooser_boolean});
defineParam('ricochet4_false',  {name: "rico", value: false, ui: chooser_boolean});

function stringParamBeatsNotN (n) {
  return function (value) {return value.toString();};
}
// do not use param_beats without a default number of beats - it causes dance validation explosions in the editor -dm 08-14-2018
//  defineParam('beats',    {name: "beats",           ui: chooser_beats, string: stringParamBeatsNotN(-100)});
defineParam('beats_0',  {name: "beats", value: 0, ui: chooser_beats, string: stringParamBeatsNotN(0)});
defineParam('beats_2',  {name: "beats", value: 2, ui: chooser_beats, string: stringParamBeatsNotN(2)});
defineParam('beats_4',  {name: "beats", value: 4, ui: chooser_beats, string: stringParamBeatsNotN(4)});
defineParam('beats_6',  {name: "beats", value: 6, ui: chooser_beats, string: stringParamBeatsNotN(6)});
defineParam('beats_8',  {name: "beats", value: 8, ui: chooser_beats, string: stringParamBeatsNotN(8)});
defineParam('beats_12',  {name: "beats", value: 12, ui: chooser_beats, string: stringParamBeatsNotN(12)});
defineParam('beats_16',  {name: "beats", value: 16, ui: chooser_beats, string: stringParamBeatsNotN(16)});

function makeTurnStringParam(left, right, asterisk, null_) {
  return function(value) {
    if (value) {
      if ('*'===value) {
        return asterisk;
      } else {
        return left;
      }
    } else {
      if (null===value) {
        return null_;
      } else {
        return right;
      }
    }
  };
}
var stringParamClock = makeTurnStringParam('clockwise', 'counter-clockwise', '*', '____');
var stringParamLeftRight = makeTurnStringParam('left', 'right', '*', '____');
var stringParamShoulders = makeTurnStringParam('right shoulders', 'left shoulders', '* shoulders', '____');
var stringParamShouldersTerse = makeTurnStringParam('rights', 'lefts', '* shoulders', '____');
var stringParamHandStarHand = makeTurnStringParam('right', 'left', '* hand', '____');
var stringParamHand = makeTurnStringParam('right', 'left', '*', '____');

// spin = clockwise | ccw | undefined
defineParam('spin',                    {name: "turn",                   ui: chooser_spin, string: stringParamClock});
defineParam('spin_clockwise',          {name: "turn", value: true,      ui: chooser_spin, string: stringParamClock});
defineParam('spin_ccw',                {name: "turn", value: false,     ui: chooser_spin, string: stringParamClock});
defineParam('spin_left',               {name: "turn", value: true,      ui: chooser_left_right_spin, string: stringParamLeftRight});
defineParam('spin_right',              {name: "turn", value: false,     ui: chooser_left_right_spin, string: stringParamLeftRight});
defineParam('xhand_spin',              {name: "hand",                   ui: chooser_right_left_hand, string: stringParamHandStarHand});
defineParam('right_hand_spin',         {name: "hand", value: true,      ui: chooser_right_left_hand, string: stringParamHandStarHand});
defineParam('left_hand_spin',          {name: "hand", value: false,     ui: chooser_right_left_hand, string: stringParamHandStarHand});
defineParam('xshoulders_spin',         {name: "shoulder",               ui: chooser_right_left_shoulder, string: stringParamShoulders});
defineParam('right_shoulders_spin',    {name: "shoulder", value: true,  ui: chooser_right_left_shoulder, string: stringParamShoulders});
defineParam('rights_spin',             {name: "shoulder", value: true,  ui: chooser_right_left_shoulder, string: stringParamShouldersTerse}); // shoulder
defineParam('left_shoulders_spin',     {name: "shoulder", value: false, ui: chooser_right_left_shoulder, string: stringParamShoulders});
defineParam('by_xhand',       {name: "c.hand", ui: chooser_right_left_hand, string: stringParamHand});
defineParam('by_right_hand',  {name: "hand",   ui: chooser_right_left_hand, string: stringParamHand, value: true});

function stringParamDegrees (value,move) {
  // this second parameter should go away, it should be handled in figure.js,
  // because that's the file that knows about figures and moves.
  if (moveCaresAboutRotations(move)) {
    return degreesToRotations(value);
  } else if (moveCaresAboutPlaces(move)) {
    return degreesToPlaces(value);
  } else {
    console.log("Warning: '"+move+"' doesn't care about either rotations or places");
    return degreesToRotations(value);
  }
}
defineParam('revolutions',      {name: "circling",             ui: chooser_revolutions, string: stringParamDegrees});
defineParam('half_around',      {name: "circling", value: 180, ui: chooser_revolutions, string: stringParamDegrees});
defineParam('once_around',      {name: "circling", value: 360, ui: chooser_revolutions, string: stringParamDegrees});
defineParam('once_and_a_half',  {name: "circling", value: 540, ui: chooser_revolutions, string: stringParamDegrees});
defineParam('places',           {name: "places",             ui: chooser_places,      string: stringParamDegrees});
defineParam('two_places',       {name: "places", value: 180, ui: chooser_places,      string: stringParamDegrees});
defineParam('three_places',     {name: "places", value: 270, ui: chooser_places,      string: stringParamDegrees});
defineParam('four_places',      {name: "places", value: 360, ui: chooser_places,      string: stringParamDegrees});


// always 'everyone' and never 'everybody'!
defineParam('subject',                     {name: "who", value: "everyone",     ui: chooser_dancers});
defineParam('subject_pair',                {name: "who",                        ui: chooser_pair});  // 1 pair of dancers
defineParam('subject_pair_ladles',         {name: "who", value: "ladles",       ui: chooser_pair});
defineParam('center_pair_ladles',          {name: "center", value: "ladles",    ui: chooser_pair});
defineParam('subject_pair_gentlespoons',   {name: "who", value: "gentlespoons", ui: chooser_pair});
defineParam('subject_pair_ones',           {name: "who", value: "ones",         ui: chooser_pair});
defineParam('subject_pair_or_everyone',    {name: "who", value: "everyone",     ui: chooser_pair_or_everyone});
defineParam('subject_pairc_or_everyone',   {name: "who", value: "everyone",     ui: chooser_pairc_or_everyone}); // has `centers`
defineParam('subject_pairz',               {name: "who",                        ui: chooser_pairz}); // 1-2 pairs of dancers
defineParam('subject_pairz_partners',      {name: "who", value: "partners",     ui: chooser_pairz});
defineParam('subject_pairz_ladles',        {name: "who", value: "ladles",       ui: chooser_pairz});
defineParam('subject2_pairz_or_unspecified',  {name: "who2", value: "",         ui: chooser_pairz_or_unspecified});
defineParam('subject_pairs',               {name: "who",                        ui: chooser_pairs}); // 2 pairs of dancers
defineParam('sides_pairs_neighbors',       {name: "sides", value: "neighbors",  ui: chooser_pairs});
defineParam('subject2_pairs',              {name: "who2",                       ui: chooser_pairs});
defineParam('subject_pairs_or_everyone',   {name: "who",                        ui: chooser_pairs_or_everyone});
defineParam('subject_pairs_partners',      {name: "who", value: "partners",     ui: chooser_pairs});
defineParam('subject_dancer',              {name: "who",                        ui: chooser_dancer});
//  param_subject_role               = {name: "who",                        ui: chooser_role}; // not used
defineParam('subject_role_ladles',         {name: "who", value: "ladles",       ui: chooser_role});
defineParam('subject_role_gentlespoons',   {name: "who", value: "gentlespoons", ui: chooser_role});
//  param_subject_partners           = {name: "who", value: "partners",     ui: chooser_pairs}; // not used
//  param_subject_hetero_partners    = {name: "who", value: "partners",     ui: chooser_hetero}; // not used
defineParam('object_hetero_partners',      {name: "whom", value: "partners",    ui: chooser_hetero});
defineParam('object_dancer',               {name: "whom",                       ui: chooser_dancer});
defineParam('object_pairs',                {name: "whom",                       ui: chooser_pairs});
defineParam('object_pairs_or_ones_or_twos',  {name: "whom",                     ui: chooser_pairs_or_ones_or_twos});
defineParam('lead_dancer_l1',              {name: "lead", value: "first ladle", ui: chooser_dancer});

function formalParamIsDancers(param) {
  // harder to maintain implementation:
  // return ['who', 'who2', 'whom', 'lead'].indexOf(param.name) >= 0;
  return !!dancerMenuForChooser(param.ui);
}

function wordParamCustom(value, move_meh, dialect) {
  return lingoLineWords(stringInDialect(value, dialect), dialect);
}

// so if you use param_custom_figure, you have to use parameter_words
// instead of parameter_strings. (unless you use the default figure
// printer, which takes care of it for you, c.f. contra corners)
defineParam('custom_figure',  {name: "custom", value: "", ui: chooser_text, words: wordParamCustom});

var wristGrips = ['', 'wrist grip', 'hands across'];

function stringParamStarGrip (value) {
  return ('*' === value) ? 'any grip' : value;
}

defineParam('star_grip',  {name: "grip", value: wristGrips[0], ui: chooser_star_grip, string: stringParamStarGrip});

function stringParamMarchForward (value) {
  if (value) {
    return (value === 'forward') ? '' : value;
  } else {
    return "facing ____";
  }
}

defineParam('march_facing',  {name: "facing", ui: chooser_march_facing});
defineParam('march_forward',  {name: "facing", ui: chooser_march_facing, value: "forward", string: stringParamMarchForward});

function stringParamSlide (value) {
  if (value === '*') {
    return '*';
  } else if (value) {
    return 'left';
  } else {
    return 'right';
  }
}

defineParam('slide',        {name: "slide",              ui: chooser_slide, string: stringParamSlide});
defineParam('slide_left',   {name: "slide", value: true, ui: chooser_slide, string: stringParamSlide});
defineParam('slide_right',  {name: "slide", value: false, ui: chooser_slide, string: stringParamSlide});

function stringParamSetDirection(value) {
  if (value === 'across') {
    return 'across the set';
  } else if (value === 'along') {
    return 'along the set';
  } else if (['right diagonal', 'left diagonal','*',undefined].indexOf(value) >= 0) {
    return value;
  } else {
    throw_up('unexpected set direction value: '+ value);
  }
}

function stringParamSetDirectionSilencingDefault(value_default) {
  return function(value) {
    return (value === value_default) ? '' : stringParamSetDirection(value);
  };
}

defineParam('set_direction',         {name: "dir", ui: chooser_set_direction,                  string: stringParamSetDirection});
defineParam('set_direction_along',   {name: "dir", ui: chooser_set_direction, value: "along",  string: stringParamSetDirectionSilencingDefault('along')});
defineParam('set_direction_across',  {name: "dir", ui: chooser_set_direction, value: "across", string: stringParamSetDirectionSilencingDefault('across')});
defineParam('set_direction_grid',    {name: "dir", ui: chooser_set_direction_grid,             string: stringParamSetDirectionSilencingDefault('nope')});
defineParam('set_direction_acrossish',  {name: "dir", ui: chooser_set_direction_acrossish, value: "across", string: stringParamSetDirectionSilencingDefault('across')});
defineParam('set_direction_figure_8',  {name: "dir", ui: chooser_set_direction_figure_8, value: ""}); // '', 'across', 'above', 'below'

function stringParamSliceReturn (value) {
  if      ('straight' === value) { return 'and straight back'; }
  else if ('diagonal' === value) { return 'and diagonal back'; }
  else if ('none'     === value) { return ''; }
  else if ('*'        === value) { return 'and *'; }
  else { throw_up('bad slice return value: '+value); }
}

defineParam('slice_return',  {name: "slice return", ui: chooser_slice_return, value: 'straight', string: stringParamSliceReturn});

function stringParamSliceIncrement (value) {
  if      ('couple' === value) { return ''; }
  else if ('dancer' === value) { return 'one dancer'; }
  else if ('*'       === value) { return 'one *'; }
  else { throw_up('bad slice increment: '+value); }
}

defineParam('slice_increment',  {name: "slice increment", ui: chooser_slice_increment, value: 'couple', string: stringParamSliceIncrement});

defineParam('all_or_center_or_outsides',  {name: "moving", ui: chooser_all_or_center_or_outsides, value: 'all'});


function stringParamDownTheHallEnder (value) {
  if      ('' === value)              { return ''; }
  else if ('turn-couple'   === value) { return 'turn as a couple'; }
  else if ('turn-alone'    === value) { return 'turn alone'; }
  else if ('circle'        === value) { return 'bend into a ring'; }
  else if ('cozy'          === value) { return 'form a cozy line'; }
  else if ('cloverleaf'    === value) { return 'bend into a cloverleaf';}
  else if ('thread-needle' === value) { return 'thread the needle';}
  else if ('right-high'    === value) { return 'right hand high, left hand low';}
  else if ('sliding-doors' === value) { return 'slide doors';}
  else if ('*'             === value) { return 'end however'; }
  else { throw_up('bad down the hall ender: '+value); }
}

defineParam('down_the_hall_ender',               {name: "ender", ui: chooser_down_the_hall_ender, value: '',       string: stringParamDownTheHallEnder});
defineParam('down_the_hall_ender_circle',        {name: "ender", ui: chooser_down_the_hall_ender, value: 'circle', string: stringParamDownTheHallEnder});
defineParam('down_the_hall_ender_turn_couples',  {name: "ender", ui: chooser_down_the_hall_ender, value: 'turn-couple', string: stringParamDownTheHallEnder});

function stringParamZigZagEnder (value) {
  if ('' === value) {
    return '';
  } else if ('ring' === value) {
    return 'into a ring';
  } else if ('allemande' === value) {
    return 'trailing two catching hands';
  } else if ('*' === value) {
    return 'ending however';
  }  else {
    throw_up('bad zig zag ender: '+value);
  }
}

defineParam('zig_zag_ender',  {name: "ender", ui: chooser_zig_zag_ender, value: '', string: stringParamZigZagEnder});

defineParam('go_back',  {name: "go", ui: chooser_go_back, value: true});
defineParam('give',  {name: "give", ui: chooser_give, value: true});

var _stringParamGateFace = {up: 'up the set', down: 'down the set', 'in': 'into the set', out: 'out of the set', '*': 'any direction'};

function stringParamGateFace (value) {
  return _stringParamGateFace[value];
}

defineParam('gate_face',  {name: "face", ui: chooser_gate_direction, string: stringParamGateFace});

function stringParamHalfOrFullNotN(default_value) {
  return function (value) {
    if (default_value === value) {
      return '';
    } else if (0.5 === value) {
      return 'half';
    } else if (1.0 === value) {
      return 'full';
    } else if ('*' === value) {
      return '*';
    } else {
      throw_up('bad half_or_full parameter value: '+value+' of type '+ (typeof value));
    }
  };
}

defineParam('half_or_full',        {name: "half",              ui: chooser_half_or_full, string: stringParamHalfOrFullNotN(-100.0)});
defineParam('half_or_full_half',   {name: "half", value: 0.5,  ui: chooser_half_or_full, string: stringParamHalfOrFullNotN(0.5)});
defineParam('half_or_full_half_chatty_half',  {name: "half", value: 0.5,  ui: chooser_half_or_full, string: stringParamHalfOrFullNotN(1.0)}); // hey is chatty about its halfness, but mum about fullness
defineParam('half_or_full_half_chatty_max',   {name: "half", value: 0.5,  ui: chooser_half_or_full, string: stringParamHalfOrFullNotN(-100)}); // poussette is chatty about both halfness and fullness
defineParam('half_or_full_full',   {name: "half", value: 1.0,  ui: chooser_half_or_full, string: stringParamHalfOrFullNotN(1.0)});

defineParam('hey_length_half',  {name: "until", value: 'half', ui: chooser_hey_length, string: stringParamHeyLength});

function stringParamHeyLength(value, move, dialect) {
  if (value === 'full' || value === 'half' || value === '*') {
    return value;
  } else if (value === null) {
    return '____';
  } else if (value === 'less than half') {
    return 'until someone meets';
  } else if (value === 'between half and full') {
    return 'until someone meets the second time';
  } else {
    var pair = parseHeyLength(value);
    var dancer = pair[0];
    var meeting =  pair[1] === 2 ? ' meet the second time' : ' meet';
    return 'until ' + dancerSubstitution(dancer, dialect) + meeting;
  }
}
