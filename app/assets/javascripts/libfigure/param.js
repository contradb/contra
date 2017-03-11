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

function stringParamClock     (value) {return value ? "clockwise" : "counter-clockwise"} // untested
function stringParamLeftRight (value) {return value ? "to the left" : "to the right"}
function stringParamHand      (value) {return value ? "right" : "left"}
function stringParamShoulder  (value) {return value ? "by the right shoulder" : "by the left shoulder"} // untested

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
    return value ? "passing left sides" : "passing right sides"
}

function stringParamDegrees (value,move) {
    if (moveCaresAboutRotations(move))
    return degreesToRotations(value)
    else if (moveCaresAboutPlaces(move))
    return degreesToPlaces(value)
    else {
        console.log("Warning: '"+move+"' doesn't care about either rotations or places");
        return degreesToRotations(value)
    }
}
param_revolutions     = {name: "circling",             ui: chooser_revolutions, string: stringParamDegrees}
param_half_around     = {name: "circling", value: 180, ui: chooser_revolutions, string: stringParamDegrees}
param_once_around     = {name: "circling", value: 360, ui: chooser_revolutions, string: stringParamDegrees}
param_once_and_a_half = {name: "cirlcing", value: 540, ui: chooser_revolutions, string: stringParamDegrees}
param_three_places    = {name: "places", value: 270, ui: chooser_places,      string: stringParamDegrees}
param_four_places     = {name: "places", value: 360, ui: chooser_places,      string: stringParamDegrees}

param_subject         = {name: "who", value: "everyone", ui: chooser_dancers}
param_subject_pair    = {name: "who",                    ui: chooser_pair}  // 1 pair of dancers
param_subject_pairz   = {name: "who",                    ui: chooser_pairz} // 1-2 pairs of dancers
param_subject_pairz_partners = {name: "who", value: "partners", ui: chooser_pairz}
param_subject_pairs   = {name: "who",                    ui: chooser_pairs} // 2 pairs of dancers
param_subject_pairs_partners = {name: "who", value: "partners", ui: chooser_pairs}
param_subject_dancer  = {name: "who",                    ui: chooser_dancer}
param_subject_role              = {name: "who",                        ui: chooser_role}
param_subject_role_ladles       = {name: "who", value: "ladles",       ui: chooser_role}
param_subject_role_gentlespoons = {name: "who", value: "gentlespoons", ui: chooser_role}
param_subject_hetero           = {name: "who",                     ui: chooser_hetero}
param_subject_hetero_partners  = {name: "who", value: "partners",  ui: chooser_hetero}
param_subject_hetero_neighbors = {name: "who", value: "neighbors", ui: chooser_hetero}
param_subject_hetero_shadows   = {name: "who", value: "shadows",   ui: chooser_hetero}
param_subject_partners         = {name: "who", value: "partners",  ui: chooser_pairs} // allows more options if they
param_subject_neighbors        = {name: "who", value: "neighbors", ui: chooser_pairs} // don't go with default
param_subject_shadows          = {name: "who", value: "shadows",   ui: chooser_pairs} // than param_subject_hetero_*
// param_object_hetero           = {name: "whom",                     ui: chooser_hetero} not used
param_object_hetero_partners     = {name: "whom", value: "partners",  ui: chooser_hetero}
// param_object_hetero_neighbors = {name: "whom", value: "neighbors", ui: chooser_hetero} not used

// not used anymore
// param_pass_on_left = {name: "pass", value: false, ui: chooser_right_left_shoulder}
// param_pass_on_right = {name: "pass", value: true, ui: chooser_right_left_shoulder}

param_custom_figure = {name: "custom", value: "", ui: chooser_text}

function stringParamWristGrip (value,move) {
    // wrist grip is so defaulty that it's not even worth saying words. 
    return value ? "" : "hands across"
}

param_star_grip = {name: "grip", value: "wrist grip", ui: chooser_star_grip, string: stringParamWristGrip}

function stringParamFacing (value) {
  return (value === 'forward') ? '' : value;
}

param_facing         = {name: "facing", ui: chooser_facing}
param_facing_forward = {name: "facing", ui: chooser_facing, value: "forward", string: stringParamFacing}

function stringParamSlide (value) {
  return value ? 'left' : 'right';
}

param_slide       = {name: "slide",              ui: chooser_slide, string: stringParamSlide};
param_slide_left  = {name: "slide", value: true, ui: chooser_slide, string: stringParamSlide};
param_slide_right = {name: "slide", value: false, ui: chooser_slide, string: stringParamSlide};
