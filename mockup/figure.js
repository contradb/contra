// throw is a keyword and can't be in expressions, but function calls can be, so wrap throw.
function throw_up(str) {
    throw new Error(str)
}

var defined_figures = {}

function defineFigure (name, parameters, renderer_or_null) {
    defined_figures[name] = {name: name, parameters: parameters, renderer: renderer_or_null||null}
    // console.log("defineFigure "+ name+"="+JSON.stringify(defined_figures[name]))
}
function defineFigureAlias (newName, targetName, parameter_defaults) {
    "string" == typeof newName || throw_up("first argument isn't a string")
    "string" == typeof targetName || throw_up("second argument isn't a string")
    Array.isArray(parameter_defaults) || throw_up("third argument isn't an array aliasing "+newName)
    // console.log("defineFigureAlias "+newName+" to "+targetName+": "+defined_figures[targetName])
    var target = defined_figures[targetName] || 
        throw_up("undefined figure alias '"+newName +"' to '"+targetName+"'")
    (target.parameters.length >= parameter_defaults.length) ||
        throw_up("oversupply of parameters to "+newName)
    // defensively copy parameter_defaults[...]{...} into params
    var params = new Array(target.parameters.length)
    for (var i=0; i<target.parameters.length; i++) {
        params[i] = Object.create(parameter_defaults[i]||{});
        target.parameters[i].name == params[i].name ||
            null == params[i].name ||
            throw_up(""+newName+": parameter name/order mismatch on param #"+i+" (zero indexed)")
        for (var a in params[i])
            params[i][a] = params[i][a] || target.parameters[i][a]; // default to alias if unspecified
    }
    defined_figures[newName] =
        {name: targetName,
         parameters: params,
         renderer: target.renderer}
}


var chooser_boolean = "chooser_boolean"
var chooser_beats = "chooser_beats"
var chooser_spin = "chooser_spin"
var chooser_left_right_spin = "chooser_left_right_spin"
var chooser_right_left_hand = "chooser_right_left_hand"
var chooser_right_left_shoulder = "chooser_right_left_shoulder"
var chooser_revolutions = "chooser_revolutions"
var chooser_places = "chooser_places"
var chooser_dancers = "chooser_dancers"  // some collection of dancers
var chooser_pairz = "chooser_pairz"      // 1-2 pairs of dancers
var chooser_dancer = "chooser_dancer"    // one dancer, e.g. ladle 1
var chooser_role = "chooser_role"        // ladles or gentlespoons


param_balance_true = {name: "balance", value: true, ui: chooser_boolean}
param_balance_false = {name: "balance", value: false, ui: chooser_boolean}

param_beats_4 = {name: "beats", value: 4, ui: chooser_beats}
param_beats_8 = {name: "beats", value: 8, ui: chooser_beats}
param_beats_12 = {name: "beats", value: 12, ui: chooser_beats}
param_beats_16 = {name: "beats", value: 16, ui: chooser_beats}

// spin = clockwise | ccw | undefined
param_spin                   = {name: "spin",               ui: chooser_spin}
param_spin_clockwise         = {name: "spin", value: true,  ui: chooser_spin}
param_spin_ccw               = {name: "spin", value: false, ui: chooser_spin} 
param_spin_left              = {name: "spin", value: true,  ui: chooser_left_right_spin}
param_spin_right             = {name: "spin", value: false, ui: chooser_left_right_spin} 
param_xhand_spin             = {name: "spin",               ui: chooser_right_left_hand}
param_right_hand_spin        = {name: "spin", value: true,  ui: chooser_right_left_hand}
param_left_hand_spin         = {name: "spin", value: false, ui: chooser_right_left_hand}
param_xshoulder_spin         = {name: "spin",               ui: chooser_right_left_shoulder}
param_right_shoulder_spin    = {name: "spin", value: true,  ui: chooser_right_left_shoulder}
param_left_shoulder_spin     = {name: "spin", value: false, ui: chooser_right_left_shoulder}

param_revolutions     = {name: "degrees",             ui: chooser_revolutions}
param_half_around     = {name: "degrees", value: 180, ui: chooser_revolutions}
param_once_around     = {name: "degrees", value: 360, ui: chooser_revolutions}
param_once_and_a_half = {name: "degrees", value: 540, ui: chooser_revolutions}
param_three_places    = {name: "degrees", value: 270, ui: chooser_places}
param_four_places     = {name: "degrees", value: 360, ui: chooser_places}

param_subject         = {name: "who", value: "everyone", ui: chooser_dancers}
param_subject_pairz   = {name: "who",                    ui: chooser_pairz}
param_subject_dancer  = {name: "who",                    ui: chooser_dancer}
param_subject_role_ladles       = {name: "who", value: "ladies",       ui: chooser_role}
param_subject_role_gentlespoons = {name: "who", value: "gentlespoons", ui: chooser_role}

defineFigure( "swing",                           [param_balance_false, param_beats_8])
defineFigureAlias( "long swing",        "swing", [param_balance_false, param_beats_16])
defineFigureAlias( "balance and swing", "swing", [param_balance_true,  param_beats_16])

defineFigure( "allemande", [param_subject_pairz, param_xhand_spin, param_once_around, param_beats_8])
defineFigure( "allemande left", "allemande" [null, param_left_hand_spin])
defineFigure( "allemande right", "allemande" [null, param_right_hand_spin])

defineFigure( "do_si_do", [param_subject_pairz, param_right_shoulder_spin, param_once_around, param_beats_8])
defineFigureAlias( "see_saw", "do_si_do", [null, param_left_shoulder_spin])

defineFigure( "gyre", [param_subject_pairz, param_right_shoulder_spin, param_once_around, param_beats_8])

defineFigure( "circle",                   [param_spin_left,  param_four_places, param_beats_8])
defineFigureAlias( "circle three places", "circle", [param_spin_left,  param_three_places, param_beats_8])
defineFigureAlias( "circle right",        "circle", [param_spin_right, param_four_places, param_beats_8])

defineFigure( "long lines",               [param_beats_8])
defineFigure( "long lines forward only",  [param_beats_4])

defineFigure( "hey",                      [param_subject_role_ladles, param_beats_16])
defineFigure( "half hey",              [param_subject_role_ladles, param_beats_8])
defineFigureAlias( "hey halfway", "half hey", [])

// console.log("defined_figures:")
// console.log(JSON.stringify(defined_figures))
