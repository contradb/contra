

// always freshly allocated
function newFigure () {
    return { parameter_values: [] }
}


function figureBeats (f) {
  var defaultBeats = 8;
  if (! f.move) return defaultBeats;
  var idx = find_parameter_index_by_name("beats", parameters(f.move))
  if (idx<0)
    return defaultBeats;
  else
    return f.parameter_values[idx]
}

function sumBeats(figures,optional_limit) {
    var acc = 0;
    var n = isInteger(optional_limit) ? optional_limit : figures.length;
    for (var i = 0; i < n; i++)
        acc += figureBeats(figures[i]);
    return acc;
}

function figure_html_readonly(f) {
  var fig_def = defined_events[f.move];
  if (fig_def) {
    var func = fig_def.props.view || figure_html_readonly_default;
    var main = func(f.move, f.parameter_values);
    var note = f.note
    return note ? words(main,note) : main
  }
  else if (f.move)
    return "rogue figure '"+f.move+"'!";
  else
    return "empty figure";
}


// Called if they don't specify a view function in the figure definition:
function figure_html_readonly_default(move, parameter_values) {
    // todo: clean this up so it's not so obnoxiously ugly
    var ps = parameters(move);
    var pstrings = parameter_strings(move, parameter_values)
    var acc = ""
    var subject_index = find_parameter_index_by_name("who", ps);
    var balance_index = find_parameter_index_by_name("bal", ps);
    var beats_index   = find_parameter_index_by_name("beats",ps);
    if (subject_index >= 0) acc += pstrings[subject_index] + ' ';
    if (balance_index >= 0) acc += pstrings[balance_index] + ' ';
    acc += move;
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

function find_parameter_index_by_name(name, parameters) {
  var match_name_fn = function(p) {return p.name === name;};
  return parameters.findIndex(match_name_fn, parameters);
}

var progressionString = "to new neighbors"

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


// === Teaching Names =============

function teachingName(move) {
  return teachingNames[move] || deAliasMove(move)
}

// teach this figure under its own name, not the name of it's root figure
function defineTeachingName(alias_move) {
  teachingNames[alias_move] = alias_move;
}

var teachingNames = {};

//      _       __ _            _____ _                      
//   __| | ___ / _(_)_ __   ___|  ___(_) __ _ _   _ _ __ ___ 
//  / _` |/ _ \ |_| | '_ \ / _ \ |_  | |/ _` | | | | '__/ _ \
// | (_| |  __/  _| | | | |  __/  _| | | (_| | |_| | | |  __/
//  \__,_|\___|_| |_|_| |_|\___|_|   |_|\__, |\__,_|_|  \___|
//                                      |___/                
// language construct for defining dance moves

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

function deAliasMove(move) {
    return defined_events[move].name;
}

function moves() {
    var a = [];
    $.each(defined_events,function(k,v){a.push(k)})
    return a.sort();
}

var issued_parameter_warning = false;

function parameters(move){
    var fig = defined_events[move];
    if (fig)
        return fig.parameters
    if (move && !issued_parameter_warning)
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
                 "while the", who ? dancersComplement(who) : "others", "orbit",
                 dir ? "clockwise" : "counter clockwise",
                 souter_angle, "around", sbeats)
}

defineFigure( "allemande orbit", [param_subject_pair, param_left_hand_spin, param_once_and_a_half, param_half_around, param_beats_8], {view: allemande_orbit_view, labels: ["","allemande","","while the rest orbit", "outside for"]})

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

defineFigure( "balance", [param_subject_pairz, param_beats_4])

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
defineTeachingName("swat the flea")

////////////////////////////////////////////////
// BUTTERFLY WHIRL                            //
////////////////////////////////////////////////

defineFigure( "butterfly whirl", [param_beats_4])

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
  // this is a lot like the default view, except without the word "custom" cluttering up the front of the string.
  // var [custom,beats] = pvs
  var [scustom,sbeats] = parameter_strings(move, pvs);
  return words(scustom,sbeats);
}

defineFigure( "custom", [param_custom_figure, param_beats_8], {view: custom_view})

////////////////////////////////////////////////
// CUSTOM YUCKY                               //
////////////////////////////////////////////////

// under the earlier versions of ContraDB, custom took a balance
// parameter and a who parameter. Custom yucky provides a migration
// path, but hopefully is named yuckily enough that new users won't be
// drawn to it.

function custom_yucky_view(move,pvs) {
  var [ who,  bal,  custom, beats] = pvs
  var [swho, sbal, scustom,sbeats] = parameter_strings(move, pvs)
  return words(swho, sbal, scustom, sbeats);
}

defineFigure( "custom yucky", [param_subject, param_balance_false, param_custom_figure, param_beats_8], {view: custom_yucky_view} )

////////////////////////////////////////////////
// DO SI DO (and see saw)                     //
////////////////////////////////////////////////

function do_si_do_change(figure,index) {
    var pvs = figure.parameter_values
    var shoulder = pvs[1]
    figure.move = shoulder ? "do si do" : "see saw"
}

function do_si_do_view(move, pvs) {
  var [who,   shoulder,  rots,  beats] = pvs
  var [swho, sshoulder, srots, sbeats] = parameter_strings(move, pvs)
  return words(swho, move, srots)
}

defineFigure( "do si do", [param_subject_pairz, param_right_shoulder_spin, param_once_around, param_beats_8], {change: do_si_do_change, view: do_si_do_view})

defineFigureAlias( "see saw", "do si do", [null, param_left_shoulder_spin])

defineTeachingName("see saw")

////////////////////////////////////////////////
// DOWN THE HALL  &  UP THE HALL              //
////////////////////////////////////////////////

function up_or_down_the_hall_view(move, pvs) {
  var [ facing,  beats] = pvs
  var [sfacing, sbeats] = parameter_strings(move, pvs)
  return words(move, sfacing, sbeats);
}

defineFigure( "down the hall", [param_facing_forward, param_beats_8], {view: up_or_down_the_hall_view})
defineFigure( "up the hall",   [param_facing_forward, param_beats_8], {view: up_or_down_the_hall_view})

////////////////////////////////////////////////
// GYRE (aka circle by the eyes)              //
////////////////////////////////////////////////

function gyre_view(move, pvs) {
  var [who,   shoulder,  rots,  beats] = pvs
  var [swho, sshoulder, srots, sbeats] = parameter_strings(move, pvs)
  return words(swho, move, shoulder ? '' : sshoulder, srots, sbeats)
}

defineFigure( "gyre", [param_subject_pairz, param_right_shoulder_spin, param_once_around, param_beats_8], {view: gyre_view})

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
// MAD ROBIN                                  //
////////////////////////////////////////////////

function mad_robin_view(move,pvs) {
  var [ role,  angle,  beats] = pvs;
  var [srole, sangle, sbeats] = parameter_strings(move, pvs);
  return words(move, angle!==360 ? sangle + ' around' : '', srole, "step forward", sbeats); 
}

defineFigure( "mad robin",  [param_subject_role, param_once_around, param_beats_8], {view: mad_robin_view})

////////////////////////////////////////////////
// PASS THROUGH -- progression                //
////////////////////////////////////////////////


var pass_through_string = "pass through to new neighbors"
function pass_through_view(move,pvs) {
  var [beats] = pvs;
  var [sbeats] = parameter_strings(move, pvs);
  return words(pass_through_string,sbeats); 
}

defineFigure( "pass through", [param_beats_2], {progression: true, view: pass_through_view})

////////////////////////////////////////////////
// PETRONELLA                                 //
////////////////////////////////////////////////

function petronella_view(move,pvs) {
  var [balance, beats] = pvs;
  var [sbalance, sbeats] = parameter_strings(move, pvs);
  var balance_beats = 4 * !!balance;
  if (balance_beats + 4 == beats) return words(sbalance,move);
  else return words(sbalance,move,"for "+beats);
}

defineFigure( "petronella", [param_balance_true, param_beats_8], {view: petronella_view})
// supported on request: turning to the left

////////////////////////////////////////////////
// PROMENADE                                  //
////////////////////////////////////////////////

defineFigure( "promenade across", [param_subject_pairs_partners, param_by_left, param_beats_8])

////////////////////////////////////////////////
// PROGRESS -- progression                    //
////////////////////////////////////////////////

defineFigure( "progress", [param_beats_0], {progression: true})

////////////////////////////////////////////////
// PULL BY                                    //
////////////////////////////////////////////////

defineFigure( "pull by", [param_subject_pairz, param_right_hand_spin, param_beats_2])

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
    return words(swrist_grip, "star", sright_hand, splaces, sbeats)
}

defineFigure( "star", [param_xhand_spin, param_star_grip, param_four_places, param_beats_8], {view: star_view});

////////////////////////////////////////////////
// STAR PROMENADE                             //
////////////////////////////////////////////////

defineFigure( "star promenade", [param_xhand_spin, param_half_around, param_beats_4]);

////////////////////////////////////////////////
// SWING                                      //
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
  var [who,balance,beats] = pvs
  var [swho,sbalance,sbeats] = parameter_strings(move, pvs)
  var standard_beats = (balance || move != 'swing') ? (beats == 16) : (beats == 8)
  var move2 = move == 'long swing' ? move : 'swing'
  if (standard_beats) return words(swho, sbalance, move2)
  else return words(swho, sbalance, move2, 'for', beats) // not 'sbeats', because 'for 8' needs to be said explicitly sometimes
}

defineFigure( "swing", [param_subject_pairz_partners, param_balance_false, param_beats_8],
              {change: swing_change, view: swing_view})
defineFigureAlias( "long swing", "swing", [null, param_balance_false, param_beats_16])
defineFigureAlias( "balance and swing", "swing", [null, param_balance_true,  param_beats_16] )


// ////////////////////////////////////////////////
// // EVERYTHING BAGEL                           //
// ////////////////////////////////////////////////
// defineFigure( "everything bagel", [param_balance_true,
//                                    param_left_hand_spin,
//                                    param_by_right,
//                                    param_half_around,
//                                    param_subject_pairz,
//                                    param_pass_on_right,
//                                    param_star_grip,
//                                    param_custom_figure,
//                                    param_beats_8])
