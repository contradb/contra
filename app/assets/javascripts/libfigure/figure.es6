//  _____ ___ ____ _   _ ____  _____ 
// |  ___|_ _/ ___| | | |  _ \| ____|
// | |_   | | |  _| | | | |_) |  _|  
// |  _|  | | |_| | |_| |  _ <| |___ 
// |_|   |___\____|\___/|_| \_\_____|
//
// keep it sorted alphabetically

////////////////////////////////////////////////
// ALLEMANDE                                  //
////////////////////////////////////////////////

defineFigure("allemande", [param_subject_pairz, 
                           param_xhand_spin, 
                           param_once_around, 
                           param_beats_8]);

////////////////////////////////////////////////
// ALLEMANDE ORBIT                            //
////////////////////////////////////////////////

function allemandeOrbitStringify(move, pvs, prefs) {
  var [ who, dir, inner_angle, outer_angle, beats] = pvs;
  var [swho,sdir,sinner_angle,souter_angle,sbeats] = parameter_strings(move, pvs, prefs);
  var sopposite_dir = dir ? (dir === '*' ? '*' : "counter clockwise") : "clockwise";
  return words(swho, "allemande", sdir,
               sinner_angle, "around",
               "while the", who ? invertPair(who) : "others", "orbit",
               sopposite_dir,
               souter_angle, "around", sbeats);
}

defineFigure("allemande orbit",
             [param_subject_pair,
              param_left_hand_spin,
              param_once_and_a_half,
              param_half_around,
              param_beats_8],
             {
               stringify: allemandeOrbitStringify,
               labels: ["","allemande","inner","outer", "for"]
             });

defineRelatedMove2Way('allemande orbit', 'allemande');

////////////////////////////////////////////////
// BALANCE                                    //
////////////////////////////////////////////////

function balanceStringify(move, pvs, prefs) {
  var [who,beats] = pvs;
  var [swho,sbeats] = parameter_strings(move, pvs, prefs);
  return words(('everyone' == who) ? '' : swho, move, sbeats);
}

defineFigure("balance",
             [param_subject_pairs_or_everyone, param_beats_4],
             {stringify: balanceStringify});

// Note: at time of writing, auto-generation of related moves happens
// to any move with a balance - see the end of this file

////////////////////////////////////////////////
// BALANCE THE RING (see also: petronella)    //
////////////////////////////////////////////////

defineFigure("balance the ring", [param_beats_4]);

defineRelatedMove2Way('balance the ring', 'balance');

////////////////////////////////////////////////
// BOX CIRCULATE                              //
////////////////////////////////////////////////

function boxCirculateChange(figure,index) {
  var pvs = figure.parameter_values;
  const bal_index = 1;
  const beats_index = 3;
  if (index === bal_index) {
    pvs[beats_index] = pvs[bal_index] ? 8 : 4;
  }
}

function boxCirculateStringify(move, pvs, prefs) {
  var [subject, bal, spin, beats] = pvs;
  var [ssubject, sbal, sspin, sbeats] = parameter_strings(move, pvs, prefs);
  var expected_beats = bal ? 8 : 4;
  var tbeats = (beats === expected_beats) ? false : ('for '+ beats);
  var second_ssubject = subject ? invertPair(subject) : "others";
  var details = words(ssubject, 'cross while', second_ssubject, 'loop', sspin);
  return words(sbal, move, '-', details, tbeats);
}

defineFigure("box circulate",
             [param_subject_pair, param_balance_true, param_right_hand_spin, param_beats_8],
             {change: boxCirculateChange, stringify: boxCirculateStringify});

////////////////////////////////////////////////
// BOX THE GNAT                               //
////////////////////////////////////////////////

function boxTheGnatChange(figure,index) {
  var pvs = figure.parameter_values;
  var [who, balance, right_hand, beats] = pvs;
  figure.move = right_hand ? 'box the gnat' : 'swat the flea';
  // jankily modify beats to match whether balance checkbox is checked
  if (balance && beats === 4 && index !== 3) {
    pvs[3] = 8;
  } else if (!balance && beats == 8 && index !== 3) {
    pvs[3] = 4;
  }
}

function boxTheGnatStringify(move, pvs, prefs) {
  var [who,balance,hand,beats] = pvs;
  var [swho,sbalance,shand,sbeats] = parameter_strings(move, pvs, prefs);
  var standard_beats = ((beats == 8) && balance) || ((beats == 4) && !balance);
  if (standard_beats) {
    return words(swho, sbalance, move);
  } else {
    return words(swho, sbalance, move, 'for', beats);
  }
}

defineFigure("box the gnat",
             [param_subject_pairz, param_balance_false, param_right_hand_spin, param_beats_4],
             {change: boxTheGnatChange, stringify: boxTheGnatStringify});
defineFigureAlias( "swat the flea", "box the gnat",
                   [null, null, param_left_hand_spin, null],
                   {change: boxTheGnatChange, stringify: boxTheGnatStringify});
defineTeachingName("swat the flea");

////////////////////////////////////////////////
// BUTTERFLY WHIRL                            //
////////////////////////////////////////////////

defineFigure("butterfly whirl", [param_beats_4]);

////////////////////////////////////////////////
// CALIFORNIA TWIRL                           //
////////////////////////////////////////////////

defineFigure("California twirl",
             [param_subject_pairs_partners, param_beats_4]);

defineRelatedMove2Way('California twirl', 'box the gnat');

////////////////////////////////////////////////
// CHAIN                                      //
////////////////////////////////////////////////

function chainStringify(move, pvs, prefs) {
  var [ who,  diag,  beats] = pvs;
  var [swho, sdiag, sbeats] = parameter_strings(move, pvs, prefs);
  return words(sdiag, swho, move, sbeats);
}

defineFigure("chain",
             [param_subject_role_ladles, param_set_direction_across, param_beats_8],
             {stringify: chainStringify});

////////////////////////////////////////////////
// CIRCLE                                     //
////////////////////////////////////////////////

defineFigure("circle",
             [param_spin_left,  param_four_places, param_beats_8]);

////////////////////////////////////////////////
// CONTRA CORNERS                             //
////////////////////////////////////////////////

defineFigure("contra corners",
             [param_subject_pair_ones, param_custom_figure, param_beats_16]);

defineRelatedMove2Way('allemande', 'contra corners');

////////////////////////////////////////////////
// CROSS TRAILS                               //
////////////////////////////////////////////////

function crossTrailsChange(figure, index) {
  const pvs = figure.parameter_values;
  const invert = {partners: 'neighbors', neighbors: 'partners'};
  const who1 = 0;
  const who2 = 3;
  if (index === who1 && (pvs[who2] === pvs[who1] || (pvs[who2] === undefined))) {
    pvs[who2] = invert[pvs[who1]];
  } else if (index === who2 && (pvs[who1] == pvs[who2] || pvs[who1] === undefined)) {
    pvs[who1] = invert[pvs[who2]];
  }
}

function crossTrailsStringify(move, pvs, prefs) {
  var [ first_who,  first_dir,  first_shoulder,  second_who,  beats] = pvs;
  var [sfirst_who,    _ignore, sfirst_shoulder, ssecond_who, sbeats] = parameter_strings(move, pvs, prefs);
  var sfirst_dir = first_dir ? (first_dir + ' the set') :  '____';
  var ssecond_dir = {across: 'along the set', along: 'across the set', '*':'* the set'}[first_dir] || '____';
  var second_shoulder = '*'===first_shoulder ? '*' : !first_shoulder;
  var ssecond_shoulder = stringParamShoulder(second_shoulder) + (sbeats.length ? ',' : '');
  return words(move, '-',  sfirst_who, sfirst_dir, sfirst_shoulder+',', ssecond_who, ssecond_dir, ssecond_shoulder, sbeats);
}

defineFigure("cross trails",
             [param_subject_pairs,
              param_set_direction_grid,
              param_right_shoulder_spin,
              param_subject2_pairs,
              param_beats_4],
             {stringify: crossTrailsStringify, change: crossTrailsChange});

////////////////////////////////////////////////
// CUSTOM                                     //
////////////////////////////////////////////////

function customStringify(move, pvs, prefs) {
  // remove the word 'custom'
  var [scustom,sbeats] = parameter_strings(move, pvs, prefs);
  var tcustom = (scustom.trim()==='' || scustom==='*') ? 'custom' : scustom;
  return words(tcustom,sbeats);
}

defineFigure("custom", [param_custom_figure, param_beats_8], {stringify: customStringify});

////////////////////////////////////////////////
// DO SI DO (and see saw)                     //
////////////////////////////////////////////////

function doSiDoChange(figure,index) {
  var pvs = figure.parameter_values;
  var shoulder = pvs[1];
  figure.move = shoulder ? "do si do" : "see saw";
}

function doSiDoStringify(move, pvs, prefs) {
  var [who,   _shoulder,  rots,  beats] = pvs;
  var [swho, _sshoulder, srots, sbeats] = parameter_strings(move, pvs, prefs);
  return words(swho, move, srots, sbeats);
}

defineFigure("do si do",
             [param_subject_pairz, param_right_shoulder_spin, param_once_around, param_beats_8],
             {change: doSiDoChange, stringify: doSiDoStringify});

defineFigureAlias("see saw", "do si do", [null, param_left_shoulder_spin]);

defineTeachingName("see saw");

////////////////////////////////////////////////
// DOWN THE HALL  &  UP THE HALL              //
////////////////////////////////////////////////

function upOrDownTheHallStringify(move, pvs, prefs) {
  var [ facing,  ender, beats] = pvs;
  var [sfacing, sender, sbeats] = parameter_strings(move, pvs, prefs);
  if (ender === '') {
    return words(move, sfacing, sbeats);
  } else {
    return words(move, sfacing, 'and', sender, sbeats);
  }
}

defineFigure("down the hall",
             [param_march_forward, param_down_the_hall_ender_turn_couples, param_beats_8],
             {stringify: upOrDownTheHallStringify});
defineFigure("up the hall",
             [param_march_forward, param_down_the_hall_ender_circle,       param_beats_8],
             {stringify: upOrDownTheHallStringify});

defineRelatedMove2Way('down the hall', 'up the hall');

////////////////////////////////////////////////
// FIGURE 8                                   //
////////////////////////////////////////////////

function figure8Change(figure,index) {
  var pvs = figure.parameter_values;
  var [ subject,  lead, half_or_full, beats] = pvs;
  if (index === 0) { // subject
    var led_by_one_of_the_ones = ['first gentlespoon', 'first ladle'].indexOf(lead) < 0;
    var led_by_one_of_the_twos = ['second gentlespoon', 'second ladle'].indexOf(lead) < 0;
    // do the electric lead for ones and twos only
    if (('ones' === subject) && led_by_one_of_the_ones) {
      pvs[1] = 'first ladle';
    } else if (('twos' === subject) && led_by_one_of_the_twos) {
      pvs[1] = 'second ladle';
    }
  } else if (index == 2) { // half_or_full
    if (1.0 == half_or_full && beats == 8) {
      pvs[3] = 16;
    } else if (0.5 == half_or_full && beats == 16) {
      pvs[3] = 8;
    }
  }
}

function figure8Stringify(move, pvs, prefs) {
  var [ subject,  lead, half_or_full, beats] = pvs;
  var [ssubject, slead, shalf_or_full, sbeats] = parameter_strings(move, pvs, prefs);
  var dancer_role = {'first gentlespoon': 'gentlespoon',
                     'second gentlespoon': 'gentlespoon',
                     'first ladle': false,
                     'second ladle': false};
  var tlead = (subject === 'ones' || subject === 'twos') ? dancer_role[lead] : slead; 
  var the_rest = words(tlead, tlead && ('leading' + comma_unless_blank(sbeats)), sbeats);
  return words(ssubject, shalf_or_full, move+comma_unless_blank(the_rest), the_rest);
}

defineFigure("figure 8",
             [param_subject_pair_ones, param_lead_dancer_l1, param_half_or_full_half, param_beats_8],
             {stringify: figure8Stringify, change: figure8Change});

////////////////////////////////////////////////
// GATE                                       //
////////////////////////////////////////////////

function gateStringify(move, pvs, prefs) {
  var [ subject,  object,  gate_face,  beats] = pvs;
  var [ssubject, sobject, sgate_face, sbeats] = parameter_strings(move, pvs, prefs);
  return words(ssubject, move, sobject, 'to face', sgate_face, sbeats);
}

// 'ones gate twos' means: ones, extend a hand to twos - twos walk
// forward, ones back up, orbiting around the joined hands
defineFigure("gate",
             [param_subject_pair,
              param_object_pairs_or_ones_or_twos,
              param_gate_face,
              param_beats_8],
             {stringify: gateStringify});

////////////////////////////////////////////////
// GIVE AND TAKE                              //
////////////////////////////////////////////////

function giveAndTakeChange(figure,index) {
  var pvs = figure.parameter_values;
  var [who,   whom,  give,  beats] = pvs;
  if (give && beats === 4 && index !== 3) {
    pvs[3] = 8;
  } else if (!give && beats === 8 && index !== 3) {
    pvs[3] = 4;
  }
}

function giveAndTakeStringify(move, pvs, prefs) {
  var [who,   whom,  give,  beats] = pvs;
  var [swho,  swhom, sgive, sbeats] = parameter_strings(move, pvs, prefs);
  var default_beats = give ? 8 : 4;
  var final_sbeats = default_beats === beats ? '' : words('for', beats);
  var smove = give ? (give==='*' ? 'give? & take' : move) : 'take';
  return words(swho, smove, swhom, final_sbeats);
}

defineFigure("give & take",
             [param_subject_role_gentlespoons,
              param_object_hetero_partners,
              param_give,
              param_beats_8],
             {stringify: giveAndTakeStringify, change: giveAndTakeChange});

////////////////////////////////////////////////
// GYRE (aka circle by the eyes)              //
////////////////////////////////////////////////

function gyreStringify(move, pvs, prefs) {
  var [who,   shoulder,  rots,  beats] = pvs;
  var [swho, sshoulder, srots, sbeats] = parameter_strings(move, pvs, prefs);
  return words(swho, move, shoulder ? '' : sshoulder, srots, sbeats);
}

defineFigure("gyre",
             [param_subject_pairz,
              param_right_shoulder_spin,
              param_once_around,
              param_beats_8],
             {stringify: gyreStringify});

////////////////////////////////////////////////
// GYRE MELTDOWN                              //
////////////////////////////////////////////////

defineFigure("gyre meltdown", [param_subject_pairz, param_beats_16]);

defineRelatedMove2Way('gyre meltdown', 'gyre');
defineRelatedMove2Way('gyre meltdown', 'swing');

////////////////////////////////////////////////
// GYRE STAR                                  //
////////////////////////////////////////////////

function gyreStarStringify(move, pvs, prefs) {
  var [ who,  turn,  places,  beats] = pvs;
  var [swho, sturn, splaces, sbeats] = parameter_strings(move, pvs, prefs);
  var shand = turn ? ('*'===turn ? '*': 'left') : 'right';
  return words(move, sturn, splaces, 'with', swho, 'putting their', shand, 'hands in and backing up', sbeats);
}

defineFigure("gyre star",
             [param_subject_pair,
              param_spin_clockwise,
              param_places,
              param_beats_8],
             {stringify: gyreStarStringify});

defineRelatedMove2Way('gyre star', 'gyre');
defineRelatedMove2Way('gyre star', 'star');

////////////////////////////////////////////////
// HEY                                        //
////////////////////////////////////////////////

function heyChange(figure,index) {
  var pvs = figure.parameter_values;
  var half_or_full_idx = 1;
  var beats_idx = 3;
  var half_or_full = pvs[half_or_full_idx];
  var beats = pvs[beats_idx];
  if (half_or_full_idx === index && (half_or_full * beats === 8)) {
    pvs[beats_idx] = half_or_full * 16;
  }
}

function heyStringify(move, pvs, prefs) {
  var [  who,   half,  dir,  beats] = pvs;
  var [leader, shalf, sdir, sbeats] = parameter_strings(move, pvs, prefs);
  var sdir2 = dir === 'across' ? '' : sdir;
  var tbeats = beats / half === 16 ? '' : ('for '+beats);
  var thalf = (1 === half) ? false : shalf;
  return words(sdir2, thalf, move, comma, leader, "lead", tbeats);
}

defineFigure("hey",
             [param_subject_pair_ladles,
              param_half_or_full_half_chatty_half,
              param_set_direction_across,
              param_beats_8],
             {stringify: heyStringify, change: heyChange});


////////////////////////////////////////////////
// LONG LINES                                 //
////////////////////////////////////////////////

function longLinesChange(figure,index) {
  var pvs = figure.parameter_values;
  const back_index = 0;
  const beats_index = 1;
  if (index === back_index) {
    pvs[beats_index] = pvs[back_index] ? 8 : 4;
  }
}

function longLinesStringify(move, pvs, prefs) {
  var [ back,  beats] = pvs;
  var [sback, sbeats] = parameter_strings(move, pvs, prefs);
  var expected_beats = back ? 8 : 4;
  var tbeats = (beats === expected_beats) ? '' : ('for '+beats);
  var directions = back ? (back==='*' ? 'forward & maybe back' : 'forward & back') : 'forward';
  return words(move, directions, tbeats);
}

defineFigure("long lines",
             [param_go_back, param_beats_8],
             {stringify: longLinesStringify, change: longLinesChange});

////////////////////////////////////////////////
// MAD ROBIN                                  //
////////////////////////////////////////////////

function madRobinStringify(move, pvs, prefs) {
  var [ role,  angle,  beats] = pvs;
  var [srole, sangle, sbeats] = parameter_strings(move, pvs, prefs);
  var tangle = angle!==360 && (sangle + ' around');
  return words(move, tangle, comma, srole, "in front", sbeats); 
}

defineFigure("mad robin",
             [param_subject_pair, param_once_around, param_beats],
             {stringify: madRobinStringify});

////////////////////////////////////////////////
// OCEAN WAVE                                 //
////////////////////////////////////////////////

function oceanWaveStringify(move, pvs, prefs) {
  var [sbeats] = parameter_strings(move, pvs, prefs);
  return words('to', move, sbeats); 
}

defineFigure("ocean wave",  [param_beats_4], {stringify: oceanWaveStringify});

////////////////////////////////////////////////
// PASS BY                                    //
////////////////////////////////////////////////

defineFigure("pass by", [param_subject_pairz, param_right_shoulder_spin, param_beats_2]);

defineRelatedMove2Way('pass by', 'hey');
defineRelatedMove2Way('pass by', 'half hey');

////////////////////////////////////////////////
// PASS THROUGH                               //
////////////////////////////////////////////////

function passThroughStringify(move, pvs, prefs) {
  var [ dir,  spin,  beats] = pvs;
  var [sdir, sspin, sbeats] = parameter_strings(move, pvs, prefs);
  var left_shoulder_maybe = (spin && spin !== '*') ? '' : sspin;
  return words(move, left_shoulder_maybe, sdir, sbeats);
}

defineFigure("pass through",
             [param_set_direction_along, param_right_shoulder_spin, param_beats_2],
             {stringify: passThroughStringify});

defineRelatedMove2Way('pass by', 'pass through');

////////////////////////////////////////////////
// PETRONELLA                                 //
////////////////////////////////////////////////

function petronellaStringify(move, pvs, prefs) {
  var [balance, beats] = pvs;
  var [sbalance, sbeats] = parameter_strings(move, pvs, prefs);
  var balance_beats = 4 * !!balance;
  if (balance_beats + 4 == beats) return words(sbalance,move);
  else return words(sbalance,move,"for "+beats);
}

defineFigure("petronella", [param_balance_true, param_beats_8], {stringify: petronellaStringify});
// supported on request: turning to the left

////////////////////////////////////////////////
// POUSSETTE                                  //
////////////////////////////////////////////////

function poussetteStringify(move, pvs, prefs) {
  var [ half_or_full,  who,  whom,  turn, beats] = pvs;
  var [shalf_or_full, swho, swhom, sturn, sbeats] = parameter_strings(move, pvs, prefs);
  var tturn;
  if (undefined === turn) {
    tturn = '____';
  } else if ('*' === turn) {
    tturn = 'back then *';
  } else if (turn) {
    tturn = 'back then left';
  } else {
    tturn = 'back then right';
  }
  return words(shalf_or_full, move, '-', swho, 'pull', swhom, tturn, sbeats);
}

defineFigure("poussette",
             [param_half_or_full_half_chatty_max,
              param_subject_pair,
              param_object_pairs_or_ones_or_twos,
              param_spin, param_beats],
             {stringify: poussetteStringify});

////////////////////////////////////////////////
// PROMENADE                                  //
////////////////////////////////////////////////

function promenadeStringify(move, pvs, prefs) {
  var [ subject,  dir, spin,  beats] = pvs;
  var [ssubject, sdir, sspin, sbeats] = parameter_strings(move, pvs, prefs);
  var tspin = spin ? (spin==='*' ? 'on the *' : 'on the left') : (dir === 'along' ? 'on the right' : '');
  return words(ssubject, move, sdir, tspin, sbeats);
}

defineFigure("promenade",
             [param_subject_pairs_partners, param_set_direction_across, param_spin_right, param_beats_8],
             {stringify: promenadeStringify, labels: [,,'keep',]});

////////////////////////////////////////////////
// PROGRESS -- progression                    //
////////////////////////////////////////////////

defineFigure("progress", [param_beats_0], {progression: true});

////////////////////////////////////////////////
// PULL BY DANCERS                            //
////////////////////////////////////////////////

function pullDancersStringify(move, pvs, prefs) {
  var [ who,  bal,  spin,  beats] = pvs;
  var [swho, sbal, sspin, sbeats] = parameter_strings(move, pvs, prefs);
  var standard_beats = ((beats == 8) && bal) || ((beats == 2) && !bal);
  if (standard_beats) {
    return words(swho, sbal, 'pull by', sspin);
  } else {
    return words(swho, sbal, 'pull by', sspin, 'for', beats);
  }
}

defineFigure("pull by dancers",
             [param_subject_pairz, param_balance_false, param_right_hand_spin, param_beats_2],
             {stringify: pullDancersStringify});

////////////////////////////////////////////////
// PULL BY DIRECTION                          //
////////////////////////////////////////////////

function pullByDirectionStringify(move, pvs, prefs) {
  var [ bal,  dir,  spin,  beats] = pvs;
  var [sbal, sdir, sspin, sbeats] = parameter_strings(move, pvs, prefs);
  var is_diagonal = dir === 'left diagonal' || dir === 'right diagonal';
  var w;
  if (!is_diagonal) {
    w = words(sbal, 'pull by', sspin, sdir);
  } else if (('right diagonal' === dir) === spin) {
    w = words(sbal, 'pull by', sdir); // "pull by left diagonal" left hand is implicit - this makes XYZ a non-mouthful
  } else {
    w = words(sbal, 'pull by', sspin, 'hand', dir); // "pull by left hand right diagonal" - this deserves to be a mouthful
  }
  var standard_beats = ((beats == 8) && bal) || ((beats == 2) && !bal);
  return standard_beats ? w : words(w, 'for', beats);
}

defineFigure("pull by direction",
             [param_balance_false, param_set_direction_along, param_right_hand_spin, param_beats_2],
             {stringify: pullByDirectionStringify});

defineRelatedMove2Way('pull by dancers', 'pull by direction');

////////////////////////////////////////////////
// RIGHT LEFT THROUGH                         //
////////////////////////////////////////////////

function rightLeftThroughStringify(move, pvs, prefs) {
  var [ diag,  beats] = pvs;
  var [sdiag, sbeats] = parameter_strings(move, pvs, prefs);
  return words(sdiag, move, sbeats);
}

defineFigure("right left through",
             [param_set_direction_across, param_beats_8],
             {stringify: rightLeftThroughStringify});

////////////////////////////////////////////////
// ROLL AWAY                                  //
////////////////////////////////////////////////

defineFigure("roll away",
             [param_subject_pair,
              param_object_pairs_or_ones_or_twos,
              param_half_sashay_false,
              param_beats_4]);

////////////////////////////////////////////////
// RORY O'MOORE                               //
////////////////////////////////////////////////

function roryOMooreChange(figure,index) {
  var pvs = figure.parameter_values;
  const bal_index = 1;
  const beats_index = 3;
  if (index === bal_index) {
    pvs[beats_index] = pvs[bal_index] ? 8 : 4;
  }
}

function roryOMooreStringify(move, pvs, prefs) {
  var [ who,  balance,  dir,  beats] = pvs;
  var [swho, sbalance, sdir, sbeats] = parameter_strings(move, pvs, prefs);
  var standard_beats = ((beats == 8) && balance) || ((beats == 4) && !balance);
  var swho2 = (who === 'everyone') ? '' : swho;
  if (standard_beats) {
    return words(sbalance, swho2, move, sdir);
  } else {
    return words(sbalance, swho2, move, sdir, 'for', beats);
  }
}

defineFigure("Rory O'Moore",
             [param_subject_pairc_or_everyone, param_balance_true, param_slide_right, param_beats_8],
             {stringify: roryOMooreStringify, change: roryOMooreChange});

////////////////////////////////////////////////
// SLICE                                      //
////////////////////////////////////////////////

defineFigure("slice",
             [param_slide_left, param_slice_increment, param_slice_return, param_beats_8],
             {labels: ["slice","by","return"]});

////////////////////////////////////////////////
// SLIDE ALONG SET -- progression, couples    //
////////////////////////////////////////////////

function slideAlongSetStringify(move, pvs, prefs) {
  var [ dir,  beats] = pvs;
  var [sdir, sbeats] = parameter_strings(move, pvs, prefs);
  return words('slide', sdir, 'along set', sbeats, 'to new neighbors');
}

defineFigure("slide along set",
             [param_slide_left, param_beats_2],
             {progression: true, stringify: slideAlongSetStringify});

////////////////////////////////////////////////
// SQUARE THROUGH                             //
////////////////////////////////////////////////

function squareThroughChange(figure, index) {
  squareThroughChangeSubjects(figure, index);
  squareThroughChangeBeats(figure, index);
}

function squareThroughChangeSubjects(figure, index) {
  const pvs = figure.parameter_values;
  const invert = {partners: 'neighbors', neighbors: 'partners'};
  const who1 = 0;
  const who2 = 1;
  if (index === who1 && (pvs[who2] === pvs[who1] || (pvs[who2] === undefined))) {
    pvs[who2] = invert[pvs[who1]];
  } else if (index === who2 && (pvs[who1] == pvs[who2] || pvs[who1] === undefined)) {
    pvs[who1] = invert[pvs[who2]];
  }
}

function squareThroughChangeBeats(figure, index) {
  const beats_idx = 5;
  const pvs = figure.parameter_values;

  const balance_idx = 2;
  const angle_idx = 4;
  const changed_balance_or_places = (index === balance_idx) || (index === angle_idx);
  if (changed_balance_or_places) { 
    pvs[beats_idx] = squareThroughExpectedBeats(pvs);
  }
}

function squareThroughExpectedBeats(pvs) {
  const balance_idx = 2;
  const angle_idx = 4;

  const angle = pvs[angle_idx];
  const places = '*'===angle ? '*' : (angle / 90);
  if ([2,3,4,'*'].indexOf(places) < 0) {
    throw_up('unexpected number of places to squareThroughExpectedBeats');
  }
  const balance_beats = (places+1 >> 1) * 4 * pvs[balance_idx];
  const pull_by_beats = places * 2;
  return balance_beats + pull_by_beats;
}


function squareThroughStringify(move, pvs, prefs) {
  var [ subject1,  subject2,  bal,  hand,  angle,  beats] = pvs;
  var [ssubject1, ssubject2, sbal, shand, sangle, sbeats] = parameter_strings(move, pvs, prefs);
  var shand2 = hand ? ('*'===hand ? '*' : 'left') : 'right';
  var places = '*'===angle ? '*' : (angle / 90);
  var beats_unexpected = beats !== squareThroughExpectedBeats(pvs);
  var beats_not_divisible_by_four = 0 !== beats % 4;
  var tbeats = (beats_unexpected || beats_not_divisible_by_four) && sbeats;
  var placewords = {2: 'two', 3: 'three', 4: 'four', '*': '*'}[places] ||
        throw_up('unexpected number of places to squareThroughStringify');

  if (3===places) {
    return words(move, placewords, tbeats, '-', ssubject1, sbal, 'pull by', shand, comma, 'then', ssubject2, 'pull by', shand2, comma, 'then', ssubject1, sbal, 'pull by', shand);
  } else {
    var yadda_text = {2: false, 4: 'then repeat', '*': 'yadda yadda yadda'}[places];
    return words(move, placewords, tbeats, '-', ssubject1, sbal, 'pull by', shand, comma, 'then', ssubject2, 'pull by', shand2, yadda_text && comma, yadda_text);
  }
}

defineFigure("square through",
             [param_subject_pairs,
              param_subject2_pairs,
              param_balance_true,
              param_right_hand_spin,
              param_four_places,
              param_beats_16],
             {stringify: squareThroughStringify,
              change: squareThroughChange,
              labels: [,,'odd bal']
             });

////////////////////////////////////////////////
// STAR                                       //
////////////////////////////////////////////////

function starStringify(move, pvs, prefs) {
  var [ right_hand,  places,  wrist_grip,  beats] = pvs;
  var [sright_hand, splaces, swrist_grip, sbeats] = parameter_strings(move, pvs, prefs);
  if ('' === wrist_grip) {
    return words("star", sright_hand, splaces, sbeats);
  } else {
    return words("star", sright_hand, splaces, comma, swrist_grip, (beats!==8) && comma, sbeats);
  }
}

defineFigure("star",
             [param_xhand_spin, param_four_places, param_star_grip, param_beats_8],
             {stringify: starStringify});

////////////////////////////////////////////////
// STAR PROMENADE                             //
////////////////////////////////////////////////

function starPromenadeStringify(move, pvs, prefs) {
  var [ who,  dir,  angle,  beats] = pvs;
  var [swho, sdir, sangle, sbeats] = parameter_strings(move, pvs, prefs);
  return words((who != 'gentlespoons') && swho, move, sdir, sangle, sbeats);
}

defineFigure("star promenade",
             [param_subject_pair_gentlespoons, param_xhand_spin, param_half_around, param_beats_4],
             {stringify: starPromenadeStringify});

defineRelatedMove2Way('star promenade', 'allemande');
defineRelatedMove2Way('star promenade', 'promenade');
defineRelatedMove2Way('star promenade', 'butterfly whirl');

///////////////////////////////////////////////
// SWING                                      //
////////////////////////////////////////////////

function swingChange(figure,index) {
  var pvs = figure.parameter_values;
  var [who,balance,beats] = pvs;
  if (balance && index === 1 && beats <= 8) {
    beats = figure.parameter_values[2] = 16;
  }
}

function swingStringify(move, pvs, prefs) {
  var [who,balance,beats] = pvs;
  var [swho,sbalance,sbeats] = parameter_strings(move, pvs, prefs);
  var standard_beats = beats === 16 || (beats === 8 && !balance);
  var slong = ((beats === 16) && !balance) ? 'long' : '';
  if (standard_beats) {
    return words(swho, sbalance, slong, move);
  } else {
    return words(swho, sbalance, slong, move, 'for', beats);
  }
}

defineFigure("swing",
             [param_subject_pairz_partners, param_balance_false, param_beats_8],
             {change: swingChange, stringify: swingStringify});

///////////////////////////////////////////////
// TURN ALONE                                //
///////////////////////////////////////////////

function turnAloneStringify(move, pvs, prefs) {
  var [who,custom,beats] = pvs;
  var [swho,scustom,sbeats] = parameter_strings(move, pvs, prefs);
  return words(('everyone' !== who) && who, move, scustom, sbeats);
}

defineFigure("turn alone",
             [param_subject_pair_or_everyone, param_custom_figure, param_beats_4],
             {stringify: turnAloneStringify});

///////////////////////////////////////////////
// ZIG ZAG                                    //
////////////////////////////////////////////////

function zigZagStringify(move, pvs, prefs) {
  var [ spin,  ender,  beats] = pvs;
  var [sspin, sender, sbeats] = parameter_strings(move, pvs, prefs);
  var comma_maybe = (ender === 'allemande') && comma;
  var return_sspin = spin ? ('*'===spin ? '*' : 'right') : 'left';
  return words(move, sspin, 'then', return_sspin, comma_maybe, sender, (sbeats !== '') && comma_maybe, sbeats);
}

defineFigure("zig zag",
             [param_spin_left, param_zig_zag_ender, param_beats_6],
             {stringify: zigZagStringify, progression: true});
