
function figure_html_readonly(f) {
    var fig_def = defined_events[f.move];
    if (fig_def) {
        var func = fig_def.props.view || figure_html_readonly_default;
        return func(f.move, f.parameter_values);
    }
    else return "warning "+ (f.move || f);
}


// Called if they don't specify a view function in the figure definition:
function figure_html_readonly_default(move, parameter_values) {
    // todo: clean this up so it's not so obnoxiously ugly
    var ps = parameters(move);
    var pstrings = parameter_strings(move, parameter_values)
    var acc = ""
    var subject_index = find_parameter_names_index("who", ps)
    var balance_index = find_parameter_names_index("bal", ps)
    var beats_index = parameter_values.length - 1;
    if (subject_index >= 0) acc += pstrings[subject_index] + ' ';
    if (balance_index >= 0) acc += pstrings[balance_index] + ' ';
    acc += move
    ps.length == parameter_values.length || throw_up("parameter type mismatch. "+ps.length+" formals and "+parameter_values.length+" values");
    for (var i=0; i < parameter_values.length; i++) {
        if ((i != subject_index) && (i != balance_index) && (i != beats_index)) 
            acc += ' ' + pstrings[i];
    }
    if (is_progression(move)) acc += ' ' + progressionString;
    if ((beats_index >= 0) && (parameter_values[beats_index].value != ps[beats_index].value))
        acc +=  ' ' + pstrings[beats_index];
    return acc;
}

function find_parameter_names_index(name, parameters) {
    return parameters.findIndex(function(p) {return p.name == name}, parameters)
}

progressionString = "to new neighbors"

// ================

function parameter_string_helper (x,y) {
    return String(x)
}

function parameter_strings(move, parameter_values) {
    var formal_parameters = parameters(move)
    var acc = []
    for (var i=0; i<parameter_values.length; i++) {
        var string_fn = formal_parameters[i].string || parameter_string_helper
        acc.push(string_fn(parameter_values[i],move));
    }
    return acc
}


//      _       __ _            _____ _                      
//   __| | ___ / _(_)_ __   ___|  ___(_) __ _ _   _ _ __ ___ 
//  / _` |/ _ \ |_| | '_ \ / _ \ |_  | |/ _` | | | | '__/ _ \
// | (_| |  __/  _| | | | |  __/  _| | | (_| | |_| | | |  __/
//  \__,_|\___|_| |_|_| |_|\___|_|   |_|\__, |\__,_|_|  \___|
//                                      |___/                
// language construct for defining custom moves

var defined_events = {}

function defineFigure (name, parameters, props) {
    defined_events[name] = {name: name, parameters: parameters, props: (props || {})}
}

function defineFigureAlias (newName, targetName, parameter_defaults) {
    "string" == typeof newName || throw_up("first argument isn't a string")
    "string" == typeof targetName || throw_up("second argument isn't a string")
    Array.isArray(parameter_defaults) || throw_up("third argument isn't an array aliasing "+newName)
    // console.log("defineFigureAlias "+newName+" to "+targetName+": "+defined_events[targetName])
    var target = defined_events[targetName] || 
        throw_up("undefined figure alias '"+newName +"' to '"+targetName+"'")
    (target.parameters.length >= parameter_defaults.length) ||
        throw_up("oversupply of parameters to "+newName)
    // defensively copy parameter_defaults[...]{...} into params
    var params = new Array(target.parameters.length)
    for (var i=0; i<target.parameters.length; i++)
        params[i] = parameter_defaults[i] || target.parameters[i]
    defined_events[newName] =
        {name: targetName,
         parameters: params,
         props: target.props}
}

function deAliasName(move) {
    return defined_events[move].name;
}

function moves() {
    var a = [];
    $.each(defined_events,function(k,v){a.push(k)})
    return a.sort();
}
var issued_parameter_warning = false
function parameters(move){
    var fig = defined_events[move];
    if (fig)
        return fig.parameters
    if (!issued_parameter_warning)
    {
        issued_parameter_warning = true
        console.log("Warning: could not find a figure definition for '"+move+"', suppressing future warnings of this type");
    }
    return [];
}

function is_progression(move) {
  var fig_def = defined_events[move];
  return fig_def && fig_def.props && fig_def.props.progression || false;
}

//       _____ ___ ____ _   _ ____  _____ ____  
//      |  ___|_ _/ ___| | | |  _ \| ____/ ___| 
//      | |_   | | |  _| | | | |_) |  _| \___ \ 
//      |  _|  | | |_| | |_| |  _ <| |___ ___) |
//      |_|   |___\____|\___/|_| \_\_____|____/ 
//
//      (sorted alphabetically - keep it sorted)

////////////////////////////////////////////////
// ALLEMANDE ORBIT                            //
////////////////////////////////////////////////

function allemande_orbit_view(move,pvs) {
    var who = pvs[0]
    var [ who, dir, inner_angle, outer_angle, beats] = pvs
    var [swho,sdir,sinner_angle,souter_angle,sbeats] = parameter_strings(move, pvs)
    return words(swho, "allemande", sdir,
                 sinner_angle, "around",
                 "while the", dancersComplement(who), "orbit",
                 dir ? "clockwise" : "counter clockwise",
                 souter_angle, "around", sbeats)
}

defineFigure( "allemande orbit", [param_subject_pair, param_left_hand_spin, param_once_and_a_half, param_half_around, param_beats_8], {view: allemande_orbit_view, glue: ["","allemande","","while the rest orbit", "outside for"]})

////////////////////////////////////////////////
// ALLEMANDE                                  //
////////////////////////////////////////////////

defineFigure( "allemande", [param_subject_pairz, param_xhand_spin, param_once_around, param_beats_8])
// unsupport because I don't want to make the string viewers not have the word 'left' twice:
// defineFigureAlias( "allemande left", "allemande", [null, param_left_hand_spin])
// defineFigureAlias( "allemande right", "allemande", [null, param_right_hand_spin])

////////////////////////////////////////////////
// BALANCE                                    //
////////////////////////////////////////////////

function balance_view(move,pvs) {
    var [who,beats] = pvs
    var [swho,sbeats] = parameter_strings(move, pvs)
    if (4==beats) return words(swho,move)
    else return words(swho,move,sbeats)
}

defineFigure( "balance", [param_subject_pairz, param_beats_4], {view: balance_view})

////////////////////////////////////////////////
// BALANCE THE RING (see also: petronella)    //
////////////////////////////////////////////////

defineFigure( "balance the ring", [param_beats_4])

////////////////////////////////////////////////
// BOX THE GNAT                               //
////////////////////////////////////////////////


function box_the_gnat_change(figure,index) {
    var pvs = figure.parameter_values
    var [who, balance, right_hand, beats] = pvs
    figure.move = right_hand ? 'box the gnat' : 'swat the flea'
    // jankily modify beats to match whether balance checkbox is checked
    if (balance && beats == 4)
        pvs[3] = 8
    else if (!balance || beats == 8)
        pvs[3] = 4
}

function box_the_gnat_view(move,pvs) {
    var [who,balance,hand,beats] = pvs
    var [swho,sbalance,shand,sbeats] = parameter_strings(move, pvs)
    var standard_beats = ((beats == 8) && balance) || ((beats == 4) && !balance);
    if (standard_beats)
        return words(swho, sbalance, move)
    else 
        return words(swho, sbalance, move, 'for', beats)
}

defineFigure( "box the gnat", [param_subject_pairz, param_balance_false, param_right_hand_spin, param_beats_4], {change: box_the_gnat_change, view: box_the_gnat_view})
defineFigureAlias( "swat the flea", "box the gnat", [null, null, param_left_hand_spin, null], {change: box_the_gnat_change, view: box_the_gnat_view})
////////////////////////////////////////////////
// CHAIN                                      //
////////////////////////////////////////////////

defineFigure( "chain", [param_subject_role_ladles, param_beats_8])

////////////////////////////////////////////////
// CIRCLE                                     //
////////////////////////////////////////////////

function circle_rename(figure,index) {
    var pvs = figure.parameter_values
    figure.move = pvs[0] ? "circle" : "circle right"
    if (pvs[0] && (pvs[1] == 270))
        figure.move = "circle three places"
}

function circle_view(move, pvs) {
  return figure_html_readonly_default(move=="circle three places" ? "circle" : move, pvs);
}

defineFigure( "circle", [param_spin_left,  param_four_places, param_beats_8], {change: circle_rename, view: circle_view})
defineFigureAlias( "circle three places", "circle", [param_spin_left,  param_three_places, param_beats_8])
defineFigureAlias( "circle right",        "circle", [param_spin_right, param_four_places, param_beats_8])

////////////////////////////////////////////////
// CUSTOM                                     //
////////////////////////////////////////////////

function custom_view(move,pvs) {
    // this is a lot like the default, except without the word "custom" at the front.
    var [custom,beats] = pvs
    var [scustom,sbeats] = parameter_strings(move, pvs)
    if (8==beats) return scustom
    else return words(scustom,sbeats)
}

defineFigure( "custom", [param_custom_figure, param_beats_8], {view: custom_view})

////////////////////////////////////////////////
// DO SI DO (and see saw)                     //
////////////////////////////////////////////////

function do_si_do_change(figure,index) {
    var pvs = figure.parameter_values
    var shoulder = pvs[1]
    figure.move = shoulder ? "do si do" : "see saw"
}


defineFigure( "do si do", [param_subject_pairz, param_right_shoulder_spin, param_once_around, param_beats_8], {change: do_si_do_change})
defineFigureAlias( "see saw", "do si do", [null, param_left_shoulder_spin], {change: do_si_do_change})

////////////////////////////////////////////////
// GYRE (aka circle by the eyes)              //
////////////////////////////////////////////////

defineFigure( "gyre", [param_subject_pairz, param_right_shoulder_spin, param_once_around, param_beats_8])

////////////////////////////////////////////////
// HEY                                        //
////////////////////////////////////////////////

function hey_view_maker(default_beats) {
    return function (move,pvs) {
        var beats = pvs[1]
        var [leader, sbeats] = parameter_strings(move,pvs)
        if (beats == default_beats)
            return  words(move+",", leader, "lead")
        else return words(move+",", leader, "lead,", sbeats)
    }
}
function hey_rename(figure,index) {
    var pvs = figure.parameter_values
    var beats = pvs[1]
    if      (beats ==  8) figure.move = "half hey"
    else if (beats == 16) figure.move = "hey"
}

defineFigure( "hey",      [param_subject_role_ladles, param_beats_16], {view: hey_view_maker(16), change: hey_rename})
defineFigure( "half hey", [param_subject_role_ladles, param_beats_8],  {view: hey_view_maker(8), change: hey_rename})
defineFigureAlias( "hey halfway", "half hey", [])

////////////////////////////////////////////////
// LONG LINES forward and back                //
////////////////////////////////////////////////

defineFigure( "long lines",               [param_beats_8])
defineFigure( "long lines forward only",  [param_beats_4])

////////////////////////////////////////////////
// PASS THROUGH -- progression                //
////////////////////////////////////////////////

defineFigure( "pass through", [param_beats_2], {progression: true})

////////////////////////////////////////////////
// PETRONELLA                                 //
////////////////////////////////////////////////

defineFigure( "petronella", [param_balance_true, param_beats_8])
// supported on request: turning to the left, turning more than one
// place, double, triple, etc. Maybe call that move 'petrozilla'?

////////////////////////////////////////////////
// PROMENADE                                  //
////////////////////////////////////////////////

defineFigure( "promenade across", [param_subject_pairs_partners, param_by_left, param_beats_8])

////////////////////////////////////////////////
// PROGRESS -- progression                    //
////////////////////////////////////////////////

defineFigure( "progress", [param_beats_0], {progression: true})

////////////////////////////////////////////////
// RIGHT LEFT THROUGH                         //
////////////////////////////////////////////////

defineFigure( "right left through", [param_beats_8])

////////////////////////////////////////////////
// SLIDE -- progression                       //
////////////////////////////////////////////////

function slide_view(move, pvs) {
  var [direction,  beats] = pvs
  return words(move, direction ? "left" : "right", progressionString) + ((beats == 2) ? "" : (" for "+beats));
}

defineFigure( "slide", [param_spin_left, param_beats_2], {progression: true, view: slide_view})

////////////////////////////////////////////////
// STAR                                       //
////////////////////////////////////////////////

function star_view(move,pvs) {
    var [ right_hand,  wrist_grip,  places,  beats] = pvs
    var [sright_hand, swrist_grip, splaces, sbeats] = parameter_strings(move, pvs)
    return words("star", sright_hand, swrist_grip, splaces, sbeats)
}

defineFigure( "star", [param_xhand_spin, param_star_grip, param_four_places, param_beats_8], {view: star_view})

////////////////////////////////////////////////
// SWING (the fun part)                       //
////////////////////////////////////////////////

function swing_change(figure,index) {
    var pvs = figure.parameter_values
    var balance = pvs[1]
    var beats = pvs[2]
    if (balance)
        figure.move = "balance and swing"
    else if (beats < 12) 
        figure.move = "swing"
    else
        figure.move = "long swing"
}
function swing_view(move,pvs) {
    var beats   = pvs[2]
    var swho = parameter_strings(move,pvs)[0]
    var standard_beats = ((beats == 16) && (move != "swing")) ||
                         ((beats == 8) && (move == "swing"))
    if (standard_beats) return words(swho, move)
    else return words(swho, move, "for", beats) // not 'sbeats', because 'for 8' needs to be said explicitly sometimes
}

defineFigure( "swing", [param_subject_pairz_partners, param_balance_false, param_beats_8],
              {change: swing_change, view: swing_view})
defineFigureAlias( "long swing", "swing", [null, param_balance_false, param_beats_16])
defineFigureAlias( "balance and swing", "swing", [null, param_balance_true,  param_beats_16] )



