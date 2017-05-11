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

function stringParamBalance (value) {
    return value ? "balance & " : ""
}
param_balance_true  = {name: "bal", value: true,  ui: chooser_boolean, string: stringParamBalance}
param_balance_false = {name: "bal", value: false, ui: chooser_boolean, string: stringParamBalance}

function stringParamHalfSashay (value) {
    return value ? "with a half sashay" : ""
}
// param_half_sashay_true  = {name: "½sash", value: true,  ui: chooser_boolean, string: stringParamHalfSashay} not used
param_half_sashay_false = {name: "½sash", value: false, ui: chooser_boolean, string: stringParamHalfSashay}

function stringParamBeatsNotN (n) {
  return function (value) {
    return value && (value != n) ? "for "+value : ""
  }
}
param_beats_0 = {name: "beats", value: 0, ui: chooser_beats, string: stringParamBeatsNotN(0)}
param_beats_2 = {name: "beats", value: 2, ui: chooser_beats, string: stringParamBeatsNotN(2)}
param_beats_4 = {name: "beats", value: 4, ui: chooser_beats, string: stringParamBeatsNotN(4)}
param_beats_6 = {name: "beats", value: 6, ui: chooser_beats, string: stringParamBeatsNotN(6)}
param_beats_8 = {name: "beats", value: 8, ui: chooser_beats, string: stringParamBeatsNotN(8)}
param_beats_12 = {name: "beats", value: 12, ui: chooser_beats, string: stringParamBeatsNotN(12)}
param_beats_16 = {name: "beats", value: 16, ui: chooser_beats, string: stringParamBeatsNotN(16)}

function stringParamClock     (value) {return value ? "clockwise" : "counter-clockwise"}
function stringParamLeftRight (value) {return value ? "left" : "right"}
function stringParamHand      (value) {return value ? "right" : "left"}
function stringParamShoulder  (value) {return value ? "right shoulders" : "left shoulders"}

// spin = clockwise | ccw | undefined
param_spin                   = {name: "turn",               ui: chooser_spin, string: stringParamClock}
param_spin_clockwise         = {name: "turn", value: true,  ui: chooser_spin, string: stringParamClock}
param_spin_ccw               = {name: "turn", value: false, ui: chooser_spin, string: stringParamClock} 
param_spin_left              = {name: "turn", value: true,  ui: chooser_left_right_spin, string: stringParamLeftRight}
param_spin_right             = {name: "turn", value: false, ui: chooser_left_right_spin, string: stringParamLeftRight} 
param_xhand_spin             = {name: "hand",               ui: chooser_right_left_hand, string: stringParamHand}
param_right_hand_spin        = {name: "hand", value: true,  ui: chooser_right_left_hand, string: stringParamHand}
param_left_hand_spin         = {name: "hand", value: false, ui: chooser_right_left_hand, string: stringParamHand}
param_xshoulder_spin         = {name: "shoulder",               ui: chooser_right_left_shoulder, string: stringParamShoulder}
param_right_shoulder_spin    = {name: "shoulder", value: true,  ui: chooser_right_left_shoulder, string: stringParamShoulder}
param_left_shoulder_spin     = {name: "shoulder", value: false, ui: chooser_right_left_shoulder, string: stringParamShoulder}


function stringParamSide (value) {
  return value ? "passing left sides" : "passing right sides";
}

function stringParamDegrees (value,move) { 
  // this second parameter should go away, it should be handled in figure.es6,
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
param_revolutions     = {name: "circling",             ui: chooser_revolutions, string: stringParamDegrees}
param_half_around     = {name: "circling", value: 180, ui: chooser_revolutions, string: stringParamDegrees}
param_once_around     = {name: "circling", value: 360, ui: chooser_revolutions, string: stringParamDegrees}
param_once_and_a_half = {name: "cirlcing", value: 540, ui: chooser_revolutions, string: stringParamDegrees}
param_three_places    = {name: "places", value: 270, ui: chooser_places,      string: stringParamDegrees}
param_four_places     = {name: "places", value: 360, ui: chooser_places,      string: stringParamDegrees}

// always 'everyone' and never 'everybody'!
param_subject                    = {name: "who", value: "everyone",     ui: chooser_dancers};
param_subject_pair               = {name: "who",                        ui: chooser_pair};  // 1 pair of dancers
param_subject_pair_ladles        = {name: "who", value: "ladles",       ui: chooser_pair};
param_subject_pair_gentlespoons  = {name: "who", value: "gentlespoons", ui: chooser_pair};
param_subject_pairz              = {name: "who",                        ui: chooser_pairz} // 1-2 pairs of dancers
param_subject_pairz_partners     = {name: "who", value: "partners",     ui: chooser_pairz}
param_subject_pairs              = {name: "who",                        ui: chooser_pairs} // 2 pairs of dancers
param_subject2_pairs             = {name: "who2",                       ui: chooser_pairs}
param_subject_pairs_or_everyone  = {name: "who",                        ui: chooser_pairs_or_everyone}
param_subject_pairs_partners     = {name: "who", value: "partners",     ui: chooser_pairs}
param_subject_dancer             = {name: "who",                        ui: chooser_dancer}
param_subject_role               = {name: "who",                        ui: chooser_role}
param_subject_role_ladles        = {name: "who", value: "ladles",       ui: chooser_role}
param_subject_role_gentlespoons  = {name: "who", value: "gentlespoons", ui: chooser_role}
param_subject_hetero             = {name: "who",                        ui: chooser_hetero}
param_subject_hetero_partners    = {name: "who", value: "partners",     ui: chooser_hetero}
param_subject_hetero_neighbors   = {name: "who", value: "neighbors",    ui: chooser_hetero}
param_subject_hetero_shadows     = {name: "who", value: "shadows",      ui: chooser_hetero}
param_subject_partners           = {name: "who", value: "partners",     ui: chooser_pairs} // allows more options if they
param_subject_neighbors          = {name: "who", value: "neighbors",    ui: chooser_pairs} // don't go with default
param_subject_shadows            = {name: "who", value: "shadows",      ui: chooser_pairs} // than param_subject_hetero_*
param_subject_everyone_or_centers = {name: "who", value: "everyone",    ui: chooser_everyone_or_centers}
// param_object_hetero           = {name: "whom",                       ui: chooser_hetero} not used
param_object_hetero_partners     = {name: "whom", value: "partners",    ui: chooser_hetero}
param_object_pairs               = {name: "whom",                       ui: chooser_pairs}
param_lead_dancer                = {name: "lead",                       ui: chooser_dancer}

// not used anymore
// param_pass_on_left = {name: "pass", value: false, ui: chooser_right_left_shoulder}
// param_pass_on_right = {name: "pass", value: true, ui: chooser_right_left_shoulder}

param_custom_figure = {name: "custom", value: "", ui: chooser_text}

var wristGrips = ['', 'wrist grip', 'hands across']

param_star_grip = {name: "grip", value: wristGrips[0], ui: chooser_star_grip}

function stringParamFacing (value) {
  if (value) {
    return (value === 'forward') ? '' : value;
  } else {
    return "facing ?";
  }
}

param_facing         = {name: "facing", ui: chooser_facing}
param_facing_forward = {name: "facing", ui: chooser_facing, value: "forward", string: stringParamFacing}

function stringParamSlide (value) {
  return value ? 'left' : 'right';
}

param_slide       = {name: "slide",              ui: chooser_slide, string: stringParamSlide};
param_slide_left  = {name: "slide", value: true, ui: chooser_slide, string: stringParamSlide};
param_slide_right = {name: "slide", value: false, ui: chooser_slide, string: stringParamSlide};


function stringParamSetDirection(value) {
  if (value === 'across') {
    return 'across the set';
  } else if (value === 'along') {
    return 'up & down the set';
  } else if (value === 'right diagonal' || value === 'left diagonal' || value === undefined) {
    return value;
  } else {
    throw_up('unexpected set direction value: '+ value);
  }
}

function stringParamSetDirectionSilencingDefault(value_default) {
  return function(value) {
    return (value === value_default) ? '' : stringParamSetDirection(value);
  }
}

param_set_direction        = {name: "dir", ui: chooser_set_direction,                  string: stringParamSetDirection};
param_set_direction_along  = {name: "dir", ui: chooser_set_direction, value: "along",  string: stringParamSetDirectionSilencingDefault('along')};
param_set_direction_across = {name: "dir", ui: chooser_set_direction, value: "across", string: stringParamSetDirectionSilencingDefault('across')};
param_set_direction_grid   = {name: "dir", ui: chooser_set_direction_grid,             string: stringParamSetDirectionSilencingDefault('nope')};

function stringParamSliceReturn (value) {
  if      ('straight' === value) { return 'and straight back'; }
  else if ('diagonal' === value) { return 'and diagonal back'; }
  else if ('none'     === value) { return ''; }
  else { throw_up('bad slice return value: '+value); }
}

param_slice_return = {name: "slice return", ui: chooser_slice_return, value: 'straight', string: stringParamSliceReturn};

function stringParamSliceIncrement (value) {
  if      ('couple' === value) { return ''; }
  else if ('dancer' === value) { return 'one dancer'; }
  else { throw_up('bad slice increment: '+value); }
}

param_slice_increment = {name: "slice increment", ui: chooser_slice_increment, value: 'couple', string: stringParamSliceIncrement}

function stringParamDownTheHallEnder (value) {
  if      ('' === value) { return ''; }
  else if ('turn-couples' === value) { return 'turn as couples'; }
  else if ('turn-alone' === value) { return 'turn alone'; }
  else if ('circle' === value) { return 'bend into a ring'; }
  else { throw_up('bad down the hall ender: '+value); }
}

param_down_the_hall_ender              = {name: "ender", ui: chooser_down_the_hall_ender, value: '',       string: stringParamDownTheHallEnder}
param_down_the_hall_ender_circle       = {name: "ender", ui: chooser_down_the_hall_ender, value: 'circle', string: stringParamDownTheHallEnder}
param_down_the_hall_ender_turn_couples = {name: "ender", ui: chooser_down_the_hall_ender, value: 'turn-couples', string: stringParamDownTheHallEnder}

param_give = {name: "give", ui: chooser_give, value: true}

var _stringParamGateFace = {up: 'up the set', down: 'down the set', 'in': 'into the set', out: 'out of the set'};

function stringParamGateFace (value) {
  return _stringParamGateFace[value];
}

param_gate_face = {name: "face", ui: chooser_gate_direction, string: stringParamGateFace}

param_half_or_whole  = {name: "half", value: 0.5,  ui: chooser_half_or_whole}
