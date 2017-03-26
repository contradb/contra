//  -*-Javascript-*-
// In this file we can use some emca6 features such as array variable assignment. 
// That's the reason for the .es6 suffix.

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
  $.each(defined_events,function(k,v){a.push(k)});
  return a.sort(function(a,b) {
    var aa = a.toLowerCase();
    var bb = b.toLowerCase();
    if (aa < bb) { return -1 ;}
    else if (aa > bb) { return 1; }
    else { return 0; }
  });
}

var issued_parameter_warning = false;

function parameters(move){
    var fig = defined_events[move];
    if (fig)
        return fig.parameters
    if (move && !issued_parameter_warning)
    {
        issued_parameter_warning = true
        throw_up("could not find a figure definition for '"+move+"'. ");
        // console.log("Warning: could not find a figure definition for '"+move+"', suppressing future warnings of this type");
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
    var [ who, dir, inner_angle, outer_angle, beats] = pvs
    var [swho,sdir,sinner_angle,souter_angle,sbeats] = parameter_strings(move, pvs)
    return words(swho, "allemande", sdir,
                 sinner_angle, "around",
                 "while the", who ? dancersComplement(who) : "others", "orbit",
                 dir ? "counter clockwise" : "clockwise",
                 souter_angle, "around", sbeats)
}

defineFigure( "allemande orbit", [param_subject_pair, param_left_hand_spin, param_once_and_a_half, param_half_around, param_beats_8], {view: allemande_orbit_view, labels: ["","allemande","inner","outer", "for"]})

////////////////////////////////////////////////
// ALLEMANDE                                  //
////////////////////////////////////////////////

defineFigure( "allemande", [param_subject_pairz, param_xhand_spin, param_once_around, param_beats_8])

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
    if (balance && beats === 4 && index !== 3)
        pvs[3] = 8;
    else if (!balance && beats == 8 && index !== 3)
        pvs[3] = 4;
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

function chain_view(move,pvs) {
  var [ who,  diag,  beats] = pvs;
  var [swho, sdiag, sbeats] = parameter_strings(move, pvs);
  return words(sdiag, swho, move, sbeats);
}

defineFigure( "chain", [param_subject_role_ladles, param_diagonal, param_beats_8], {view: chain_view})

////////////////////////////////////////////////
// CIRCLE                                     //
////////////////////////////////////////////////

defineFigure( "circle", [param_spin_left,  param_four_places, param_beats_8])

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
  var [who,   _shoulder,  rots,  beats] = pvs
  var [swho, _sshoulder, srots, sbeats] = parameter_strings(move, pvs)
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
  return words(move, angle!==360 ? sangle + ' around' : '', '-', srole, "forward", sbeats); 
}

defineFigure( "mad robin",  [param_subject_role, param_once_around, param_beats_8], {view: mad_robin_view})

////////////////////////////////////////////////
// OCEAN WAVE                                 //
////////////////////////////////////////////////

defineFigure( "ocean wave",  [param_beats_4])

////////////////////////////////////////////////
// PASS THROUGH -- progression                //
////////////////////////////////////////////////

function pass_through_view(move,pvs) {
  var [ dir,  spin,  beats] = pvs;
  var [sdir, sspin, sbeats] = parameter_strings(move, pvs);
  var left_shoulder_maybe = spin ? '' : sspin;
  return words(move, left_shoulder_maybe, sdir, sbeats);
}

defineFigure( "pass through", [param_set_direction_along, param_right_shoulder_spin, param_beats_2], {view: pass_through_view})

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

function promenade_view(move,pvs) {
  var [ subject,  spin,  beats] = pvs;
  var [ssubject, sspin, sbeats] = parameter_strings(move, pvs);
  return words(ssubject, move, spin ? 'passing on the left' : '', sbeats);
}

defineFigure( "promenade across", [param_subject_pairs_partners, param_spin_right, param_beats_8], {view: promenade_view})

////////////////////////////////////////////////
// PROGRESS -- progression                    //
////////////////////////////////////////////////

defineFigure( "progress", [param_beats_0], {progression: true})

////////////////////////////////////////////////
// PULL BY FOR 2                              //
////////////////////////////////////////////////

function pull_by_for_2_view(move,pvs) {
  var [ who,  bal,  spin,  beats] = pvs;
  var [swho, sbal, sspin, sbeats] = parameter_strings(move, pvs);
  var left_hand = spin ? '' : 'left';
  var standard_beats = ((beats == 8) && bal) || ((beats == 2) && !bal);
  if (standard_beats) {
    return words(swho, sbal, 'pull by', left_hand);
  } else {
    return words(swho, sbal, 'pull by', left_hand, 'for', beats);
  }
}

defineFigure( "pull by for 2", [param_subject_pair, param_balance_false, param_right_hand_spin, param_beats_2], {view: pull_by_for_2_view})

////////////////////////////////////////////////
// PULL BY FOR 4                              //
////////////////////////////////////////////////

function pull_by_for_4_view(move,pvs) {
  var [ bal,  dir,  spin,  beats] = pvs;
  var [sbal, sdir, sspin, sbeats] = parameter_strings(move, pvs);
  var left_hand = spin ? '' : 'left';
  var standard_beats = ((beats == 8) && bal) || ((beats == 2) && !bal);
  if (standard_beats) {
    return words(sbal, 'pull by', left_hand, sdir);
  } else {
    return words(sbal, 'pull by', left_hand, sdir, 'for', beats);
  }
}

defineFigure( "pull by for 4", [param_balance_false, param_set_direction_along, param_right_hand_spin, param_beats_2], {view: pull_by_for_4_view})

////////////////////////////////////////////////
// RIGHT LEFT THROUGH                         //
////////////////////////////////////////////////

function right_left_through_view(move,pvs) {
  var [ diag,  beats] = pvs;
  var [sdiag, sbeats] = parameter_strings(move, pvs);
  return words(sdiag, move, sbeats);
}

defineFigure( "right left through", [param_diagonal, param_beats_8], {view: right_left_through_view})

////////////////////////////////////////////////
// ROLL AWAY                                  //
////////////////////////////////////////////////

defineFigure( "roll away", [param_subject_role_gentlespoons, param_object_hetero_partners, param_half_sashay_false, param_beats_4]);

////////////////////////////////////////////////
// RORY O'MOORE                               //
////////////////////////////////////////////////

function rory_o_moore_view(move,pvs) {
  var [ dir,  balance,  beats] = pvs
  var [sdir, sbalance, sbeats] = parameter_strings(move, pvs)
  var standard_beats = ((beats == 8) && balance) || ((beats == 4) && !balance);
  if (standard_beats) {
    return words(sbalance, move, sdir);
  } else {
    return words(sbalance, move, sdir, 'for', beats);
  }
}

defineFigure( "Rory O'Moore", [param_slide_right, param_balance_true, param_beats_8], {view: rory_o_moore_view});

////////////////////////////////////////////////
// SLIDE ALONG SET -- progression, couples    //
////////////////////////////////////////////////

function slide_along_set_view(move,pvs) {
  var [ dir,  beats] = pvs
  var [sdir, sbeats] = parameter_strings(move, pvs)
  return words('slide', sdir, 'along set', sbeats, 'to new neighbors');
}

defineFigure( "slide along set", [param_slide_left, param_beats_2], {progression: true, view: slide_along_set_view})

////////////////////////////////////////////////
// STAR                                       //
////////////////////////////////////////////////

function star_view(move,pvs) {
  var [ right_hand,  places,  wrist_grip,  beats] = pvs
  var [sright_hand, splaces, swrist_grip, sbeats] = parameter_strings(move, pvs)
  if ('' === wrist_grip) {
    return words("star", sright_hand, splaces, sbeats);
  } else {
    var comma = ',';
    return words("star", sright_hand, splaces+comma, swrist_grip + (beats===8 ? '' : comma), sbeats);
  }
}

defineFigure( "star", [param_xhand_spin, param_four_places, param_star_grip, param_beats_8], {view: star_view});

////////////////////////////////////////////////
// STAR PROMENADE                             //
////////////////////////////////////////////////

defineFigure( "star promenade", [param_xhand_spin, param_half_around, param_beats_4]);

////////////////////////////////////////////////
// SWING                                      //
////////////////////////////////////////////////

function swing_change(figure,index) {
  var pvs = figure.parameter_values;
  var [who,balance,beats] = pvs;
  if (balance && index === 1 && beats <= 8) {
    beats = figure.parameter_values[2] = 16;
  }
}

function swing_view(move,pvs) {
  var [who,balance,beats] = pvs;
  var [swho,sbalance,sbeats] = parameter_strings(move, pvs);
  var standard_beats = beats === 16 || (beats === 8 && !balance);
  var slong = ((beats === 16) && !balance) ? 'long' : '';
  if (standard_beats) {
    return words(swho, sbalance, slong, move);
  } else {
    return words(swho, sbalance, slong, move, 'for', beats);
  }
}

defineFigure( "swing", [param_subject_pairz_partners, param_balance_false, param_beats_8], {change: swing_change, view: swing_view})
