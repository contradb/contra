//  _____ ___ ____ _   _ ____  _____
// |  ___|_ _/ ___| | | |  _ \| ____|
// | |_   | | |  _| | | | |_) |  _|
// |  _|  | | |_| | |_| |  _ <| |___
// |_|   |___\____|\___/|_| \_\_____|
//
// keep it sorted alphabetically

import { param } from "./param.js"
import {
  defineFigure,
  defineFigureAlias,
  defineRelatedMove2Way,
  goodBeatsMinMaxFn,
  goodBeatsMinFn,
} from "./define-figure.js"

////////////////////////////////////////////////
// ALLEMANDE                                  //
////////////////////////////////////////////////

function allemandeGoodBeats(figure) {
  var [who, dir, angle, beats] = figure.parameter_values
  var angle_over_beats = angle / beats
  if (beats <= 0) {
    return false
  }
  return (
    (360 / 8 <= angle_over_beats && angle_over_beats <= 540 / 8) ||
    (angle === 180 && 2 <= beats && beats <= 4)
  )
}

defineFigure(
  "allemande",
  [
    param("subject_pairz"),
    param("xhand_spin"),
    param("once_around"),
    param("beats_8"),
  ],
  { goodBeats: allemandeGoodBeats }
)

////////////////////////////////////////////////
// ALLEMANDE ORBIT                            //
////////////////////////////////////////////////

function allemandeOrbitWords(move, pvs, dialect) {
  var [who, dir, inner_angle, outer_angle, beats] = pvs
  var [swho, sdir, sinner_angle, souter_angle, sbeats] = parameter_strings(
    move,
    pvs,
    dialect
  )
  var sopposite_dir = dir
    ? dir === "*"
      ? "*"
      : "counter clockwise"
    : "clockwise"
  return words(
    swho,
    "allemande",
    sdir,
    sinner_angle,
    "around",
    "while the",
    invertPair(who, dialect),
    "orbit",
    sopposite_dir,
    souter_angle,
    "around"
  )
}

defineFigure(
  "allemande orbit",
  [
    param("subject_pair"),
    param("left_hand_spin"),
    param("once_and_a_half"),
    param("half_around"),
    param("beats_8"),
  ],
  {
    words: allemandeOrbitWords,
    labels: ["", "allemande", "inner", "outer", "for"],
  }
)

defineRelatedMove2Way("allemande orbit", "allemande")

////////////////////////////////////////////////
// ARCH AND DIVE                              //
////////////////////////////////////////////////

function archAndDiveWords(move, pvs, dialect) {
  var [who, beats] = pvs
  var [swho, sbeats] = parameter_strings(move, pvs, dialect)
  // var smove = moveSubstitution(move, dialect);
  var twho = invertPair(who, dialect)
  return words(swho, "arch", twho, "dive")
}

defineFigure("arch & dive", [param("subject_pair"), param("beats_4")], {
  words: archAndDiveWords,
})

////////////////////////////////////////////////
// BALANCE                                    //
////////////////////////////////////////////////

function balanceWords(move, pvs, dialect) {
  var [who, beats] = pvs
  var [swho, sbeats] = parameter_strings(move, pvs, dialect)
  var smove = moveSubstitution(move, dialect)
  return words("everyone" == who ? "" : swho, smove)
}

defineFigure(
  "balance",
  [param("subject_pairs_or_everyone"), param("beats_4")],
  { words: balanceWords }
)

// Note: at time of writing, auto-generation of related moves happens
// to any move with a balance - see the end of this file

////////////////////////////////////////////////
// BALANCE THE RING (see also: petronella)    //
////////////////////////////////////////////////

defineFigure("balance the ring", [param("beats_4")])

defineRelatedMove2Way("balance the ring", "balance")

////////////////////////////////////////////////
// BOX CIRCULATE                              //
////////////////////////////////////////////////

function boxCirculateChange(figure, index) {
  var pvs = figure.parameter_values
  const bal_index = 1
  const beats_index = 3
  if (index === bal_index) {
    pvs[beats_index] = pvs[bal_index] ? 8 : 4
  }
}

function boxCirculateGoodBeats(figure) {
  var [subject, bal, spin, beats] = figure.parameter_values
  return beats === (bal ? 8 : 4)
}

function boxCirculateWords(move, pvs, dialect) {
  var [subject, bal, spin, beats] = pvs
  var [ssubject, sbal, sspin, sbeats] = parameter_strings(move, pvs, dialect)
  var smove = moveSubstitution(move, dialect)
  var second_ssubject = invertPair(subject, dialect)
  var details = words(ssubject, "cross while", second_ssubject, "loop", sspin)
  return words(sbal, smove, "-", details)
}

defineFigure(
  "box circulate",
  [
    param("subject_pair"),
    param("balance_true"),
    param("right_hand_spin"),
    param("beats_8"),
  ],
  {
    change: boxCirculateChange,
    words: boxCirculateWords,
    goodBeats: boxCirculateGoodBeats,
  }
)

////////////////////////////////////////////////
// BOX THE GNAT                               //
////////////////////////////////////////////////

function boxTheGnatAlias(figure) {
  var [who, balance, right_hand, beats] = figure.parameter_values
  return right_hand ? "box the gnat" : "swat the flea"
}

function boxTheGnatChange(figure, index) {
  var pvs = figure.parameter_values
  var [who, balance, right_hand, beats] = pvs
  var balance_idx = 1
  var beats_idx = 3
  // modify beats to match whether balance checkbox is checked
  if (balance && beats === 4 && index === balance_idx) {
    pvs[beats_idx] = 8
  } else if (!balance && beats == 8 && index === balance_idx) {
    pvs[beats_idx] = 4
  }
}

function boxTheGnatGoodBeats(figure) {
  var [who, balance, right_hand, beats] = figure.parameter_values
  return beats === (balance ? 8 : 4)
}

function boxTheGnatWords(move, pvs, dialect) {
  var [who, balance, hand, beats] = pvs
  var [swho, sbalance, shand, sbeats] = parameter_strings(move, pvs, dialect)
  var smove = moveSubstitution(move, dialect)
  var thand = true === balance && hand !== !hand && shand + " hand"
  return words(swho, thand, sbalance, smove)
}

defineFigure(
  "box the gnat",
  [
    param("subject_pairz"),
    param("balance_false"),
    param("right_hand_spin"),
    param("beats_4"),
  ],
  {
    change: boxTheGnatChange,
    words: boxTheGnatWords,
    alias: boxTheGnatAlias,
    goodBeats: boxTheGnatGoodBeats,
  }
)
defineFigureAlias("swat the flea", "box the gnat", [
  null,
  null,
  param("left_hand_spin"),
  null,
])

////////////////////////////////////////////////
// BUTTERFLY WHIRL                            //
////////////////////////////////////////////////

defineFigure("butterfly whirl", [param("beats_4")])

////////////////////////////////////////////////
// CALIFORNIA TWIRL                           //
////////////////////////////////////////////////

defineFigure("California twirl", [
  param("subject_pairz_partners"),
  param("beats_4"),
])

defineRelatedMove2Way("California twirl", "box the gnat")

////////////////////////////////////////////////
// CHAIN                                      //
////////////////////////////////////////////////

function chainChange(figure, index) {
  var pvs = figure.parameter_values
  const who_index = 0
  const hand_index = 1
  if (index === who_index) {
    pvs[hand_index] = pvs[who_index] === "ladles"
  }
}

function chainWords(move, pvs, dialect) {
  var [who, hand, diag, beats] = pvs
  var [swho, shand, sdiag, sbeats] = parameter_strings(move, pvs, dialect)
  var smove = moveSubstitution(move, dialect)
  var thand
  if (hand === "*") {
    thand = "*-hand"
  } else if (hand === (who === "ladles")) {
    thand = false
  } else {
    thand = shand + "-hand"
  }

  return words(sdiag, swho, thand, smove)
}

defineFigure(
  "chain",
  [
    param("subject_role_ladles"),
    param("by_right_hand"),
    param("set_direction_across"),
    param("beats_8"),
  ],
  { words: chainWords, change: chainChange }
)

////////////////////////////////////////////////
// CIRCLE                                     //
////////////////////////////////////////////////

function circleGoodBeats(figure) {
  var [dir, angle, beats] = figure.parameter_values
  var three_places_in_about_eight_beats =
    angle === 270 && 6 <= beats && beats <= 8
  var one_place_per_two_beats = angle / beats === 45
  return three_places_in_about_eight_beats || one_place_per_two_beats
}

defineFigure(
  "circle",
  [param("spin_left"), param("four_places"), param("beats_8")],
  { goodBeats: circleGoodBeats }
)

////////////////////////////////////////////////
// CONTRA CORNERS                             //
////////////////////////////////////////////////

defineFigure("contra corners", [
  param("subject_pair_ones"),
  param("custom_figure"),
  param("beats_16"),
])

defineRelatedMove2Way("allemande", "contra corners")

////////////////////////////////////////////////
// CROSS TRAILS                               //
////////////////////////////////////////////////

function crossTrailsChange(figure, index) {
  const pvs = figure.parameter_values
  const invert = { partners: "neighbors", neighbors: "partners" }
  const who1 = 0
  const who2 = 3
  if (index === who1 && (pvs[who2] === pvs[who1] || pvs[who2] === undefined)) {
    pvs[who2] = invert[pvs[who1]]
  } else if (
    index === who2 &&
    (pvs[who1] == pvs[who2] || pvs[who1] === undefined)
  ) {
    pvs[who1] = invert[pvs[who2]]
  }
}

function crossTrailsWords(move, pvs, dialect) {
  var [first_who, first_dir, first_shoulder, second_who, beats] = pvs
  var [
    sfirst_who,
    _ignore,
    sfirst_shoulder,
    ssecond_who,
    sbeats,
  ] = parameter_strings(move, pvs, dialect)
  var sfirst_dir = first_dir ? first_dir + " the set" : "____"
  var ssecond_dir =
    { across: "along the set", along: "across the set", "*": "* the set" }[
      first_dir
    ] || "____"
  var second_shoulder = "*" === first_shoulder ? "*" : !first_shoulder
  var ssecond_shoulder = stringParamShoulders(second_shoulder)
  var smove = moveSubstitution(move, dialect)
  return words(
    smove,
    "-",
    sfirst_who,
    sfirst_dir,
    sfirst_shoulder + ",",
    ssecond_who,
    ssecond_dir,
    ssecond_shoulder
  )
}

defineFigure(
  "cross trails",
  [
    param("subject_pairs"),
    param("set_direction_grid"),
    param("right_shoulders_spin"),
    param("subject2_pairs"),
    param("beats_4"),
  ],
  { words: crossTrailsWords, change: crossTrailsChange }
)

////////////////////////////////////////////////
// CUSTOM                                     //
////////////////////////////////////////////////

function customWords(move, pvs, dialect) {
  // remove the word 'custom'
  var [scustom, sbeats] = parameter_words(move, pvs, dialect)
  var ss = scustom.toHtml()
  var print_move_name = ss.trim() === "" || ss === "*"
  return print_move_name ? moveSubstitution(move, dialect) : scustom
}

defineFigure("custom", [param("custom_figure"), param("beats_8")], {
  words: customWords,
  goodBeats: function(meh) {
    return true
  },
})

////////////////////////////////////////////////
// DO SI DO (and see saw)                     //
////////////////////////////////////////////////

function doSiDoAlias(figure) {
  var right_shoulder = figure.parameter_values[1]
  return right_shoulder ? "do si do" : "see saw"
}

function doSiDoGoodBeats(figure) {
  var [who, shoulder, angle, beats] = figure.parameter_values
  var angle_over_beats = angle / beats
  return beats > 0 && 360 / 8 <= angle_over_beats && angle_over_beats <= 540 / 8
}

function doSiDoWords(move, pvs, dialect) {
  var [who, _shoulder, rots, _beats] = pvs
  var [swho, _sshoulder, srots, _sbeats] = parameter_strings(move, pvs, dialect)
  var smove = moveSubstitution(move, dialect)
  // don't say the shoulder
  return words(swho, smove, srots)
}

defineFigure(
  "do si do",
  [
    param("subject_pairz"),
    param("right_shoulders_spin"),
    param("once_around"),
    param("beats_8"),
  ],
  { words: doSiDoWords, alias: doSiDoAlias, goodBeats: doSiDoGoodBeats }
)

defineFigureAlias("see saw", "do si do", [
  null,
  param("left_shoulders_spin"),
  null,
  null,
])

////////////////////////////////////////////////
// DOLPHIN HEY                                //
////////////////////////////////////////////////

function dolphinHeyWords(move, pvs, dialect) {
  var [who, whom, shoulder, beats] = pvs
  var [swho, swhom, sshoulder, sbeats] = parameter_strings(move, pvs, dialect)
  var smove = moveSubstitution(move, dialect)
  return words(smove, "- start with", swho, "passing", swhom, "by", sshoulder)
}

defineFigure(
  "dolphin hey",
  [
    param("subject_pair"),
    param("object_dancer"),
    param("xshoulders_spin"),
    param("beats_16"),
  ],
  { words: dolphinHeyWords }
)

defineRelatedMove2Way("dolphin hey", "hey")

////////////////////////////////////////////////
// DOWN THE HALL  &  UP THE HALL              //
////////////////////////////////////////////////

function upOrDownTheHallChange(figure, index) {
  // tood
  var pvs = figure.parameter_values
  const who_index = 0
  const moving_index = 1
  if (index === who_index) {
    if (pvs[who_index] === "everyone") {
      pvs[moving_index] = "all"
    } else if (pvs[moving_index] === "all") {
      pvs[moving_index] = "center"
    }
  } else if (index === moving_index) {
    if (pvs[moving_index] === "all") {
      pvs[who_index] = "everyone"
    } else if (pvs[who_index] === "everyone") {
      pvs[who_index] = "ones"
    }
  }
}

function upOrDownTheHallWords(move, pvs, dialect) {
  var [who, moving, facing, ender, beats] = pvs
  var [swho, smoving, sfacing, sender, sbeats] = parameter_strings(
    move,
    pvs,
    dialect
  )
  var smove = moveSubstitution(move, dialect)
  var twho = who === "everyone" ? "" : swho
  var tmove
  if (moving === "all") {
    tmove = smove // down-the-hall
  } else if (move === "down the hall") {
    tmove = "down the " + smoving
  } else if (move === "up the hall") {
    tmove = "up the " + smoving
  } else {
    throw_up("what move is this even anyway?")
  }

  if (ender === "") {
    return words(twho, tmove, sfacing)
  } else {
    return words(twho, tmove, sfacing, "and", sender)
  }
}

defineFigure(
  "down the hall",
  [
    param("subject_pair_or_everyone"),
    param("all_or_center_or_outsides"),
    param("march_forward"),
    param("down_the_hall_ender_turn_couples"),
    param("beats_8"),
  ],
  { change: upOrDownTheHallChange, words: upOrDownTheHallWords }
)
defineFigure(
  "up the hall",
  [
    param("subject_pair_or_everyone"),
    param("all_or_center_or_outsides"),
    param("march_forward"),
    param("down_the_hall_ender_circle"),
    param("beats_8"),
  ],
  { change: upOrDownTheHallChange, words: upOrDownTheHallWords }
)

defineRelatedMove2Way("down the hall", "up the hall")

////////////////////////////////////////////////
// FIGURE 8                                   //
////////////////////////////////////////////////

function figure8Change(figure, index) {
  var pvs = figure.parameter_values
  var [subject, dir, lead, half_or_full, beats] = pvs
  var subject_idx = 0
  var lead_idx = 2
  var half_or_full_idx = 3
  var beats_idx = 4
  if (index === subject_idx) {
    var not_led_by_one_of_the_ones =
      ["first gentlespoon", "first ladle"].indexOf(lead) < 0
    var not_led_by_one_of_the_twos =
      ["second gentlespoon", "second ladle"].indexOf(lead) < 0
    // do the electric lead for ones and twos only
    if ("ones" === subject && not_led_by_one_of_the_ones) {
      pvs[lead_idx] = "first ladle"
    } else if ("twos" === subject && not_led_by_one_of_the_twos) {
      pvs[lead_idx] = "second ladle"
    }
  } else if (index == half_or_full_idx) {
    if (1.0 == half_or_full && beats == 8) {
      pvs[beats_idx] = 16
    } else if (0.5 == half_or_full && beats == 16) {
      pvs[beats_idx] = 8
    }
  }
}

function figure8GoodBeats(figure) {
  var [subject, dir, lead, half_or_full, beats] = figure.parameter_values
  return beats === half_or_full * 16
}

function figure8Words(move, pvs, dialect) {
  var [subject, dir, lead, half_or_full, beats] = pvs
  var [ssubject, sdir, slead, shalf_or_full, sbeats] = parameter_strings(
    move,
    pvs,
    dialect
  )
  var smove = moveSubstitution(move, dialect)
  var tlead =
    (subject === "ones" && lead === "first ladle") ||
    (subject === "twos" && lead === "second ladle")
      ? ""
      : slead
  var the_rest = words(tlead, tlead && "leading")
  var lead_description = words(tlead, tlead && "leading")
  return words(
    ssubject,
    shalf_or_full,
    smove,
    sdir,
    tlead && comma,
    tlead && lead_description
  )
}

defineFigure(
  "figure 8",
  [
    param("subject_pair_ones"),
    param("set_direction_figure_8"),
    param("lead_dancer_l1"),
    param("half_or_full_half_chatty_max"),
    param("beats_8"),
  ],
  { words: figure8Words, change: figure8Change, goodBeats: figure8GoodBeats }
)

////////////////////////////////////////////////
// FORM LONG WAVES                            //
////////////////////////////////////////////////

function formLongWavesWords(move, pvs, dialect) {
  var [subject, beats] = pvs
  var [ssubject, sbeats] = parameter_strings(move, pvs, dialect)
  var smove = moveSubstitution(move, dialect)
  var tsubject = invertPair(subject, dialect)
  return words(smove, "-", ssubject, "face in,", tsubject, "face out")
}

defineFigure(
  "form long waves",
  [param("subject_pair_gentlespoons"), param("beats_0")],
  { words: formLongWavesWords }
)

////////////////////////////////////////////////
// FORM A LONG WAVE                           //
////////////////////////////////////////////////

function formALongWaveChange(figure, index) {
  var pvs = figure.parameter_values
  var [subject, in_, out, bal, beats] = pvs
  var in_idx = 1
  var out_idx = 2
  var bal_idx = 3
  var beats_idx = 4
  var canonical_beats = (in_ || out ? 4 : 0) + (bal ? 4 : 0)
  if (index === bal_idx || index === in_idx || index === out_idx) {
    // This could be pretty complicated. Let's simply set the beats if anything beat-related changes.
    pvs[beats_idx] = canonical_beats
  }
}

function formALongWaveGoodBeats(figure) {
  var [subject, in_, out, bal, beats] = figure.parameter_values
  return beats === (in_ || out ? 4 : 0) + (bal ? 4 : 0)
}

function formALongWaveWords(move, pvs, dialect) {
  var [subject, in_, out, bal, beats] = pvs
  var [ssubject, sin, sout, sbal, sbeats] = parameter_strings(
    move,
    pvs,
    dialect
  )
  var smove = moveSubstitution(move, dialect)
  var tsubject = invertPair(subject, dialect)
  var maybe_balance_the_wave =
    bal && (bal == "*" ? "- *" : "- balance the wave")
  if (out) {
    if (in_) {
      return words(
        tsubject,
        "dance out while",
        ssubject,
        "dance in to a long wave in the center",
        maybe_balance_the_wave
      )
    } else {
      // Weird case where they unform the wave, and optionally balance - 90% nonsense!
      // But we let them unform a wave for symmetry's sake.
      return words(tsubject, "dance out", bal && "& balance")
    }
  } else {
    if (in_) {
      return words(
        ssubject,
        "dance in to a long wave in the center",
        maybe_balance_the_wave
      )
    } else {
      return words(ssubject, smove, "in the center", maybe_balance_the_wave)
    }
  }
}

defineFigure(
  "form a long wave",
  [
    param("subject_pair_ladles"),
    param("subject_walk_in_true"),
    param("others_walk_out_false"),
    param("balance_true"),
    param("beats_8"),
  ],
  {
    words: formALongWaveWords,
    goodBeats: formALongWaveGoodBeats,
    change: formALongWaveChange,
  }
)

defineRelatedMove2Way("form a long wave", "form long waves")

////////////////////////////////////////////////
// FORM OCEAN WAVE                            //
////////////////////////////////////////////////

function formAnOceanWaveChange(figure, index) {
  var pvs = figure.parameter_values
  const pass_through_index = 0
  const bal_index = 2
  const beats_index = 6
  if (index === bal_index) {
    pvs[beats_index] = Math.max(0, pvs[beats_index] + (pvs[bal_index] ? 4 : -4))
  } else if (index === pass_through_index) {
    pvs[beats_index] = Math.max(
      0,
      pvs[beats_index] + (pvs[pass_through_index] ? 4 : -4)
    )
  }
}

function formAnOceanWaveGoodBeats(figure) {
  var [
    pass_through,
    diag,
    bal,
    center,
    center_hand,
    sides,
    beats,
  ] = figure.parameter_values
  return beats === (pass_through ? 4 : 0) + (bal ? 4 : 0)
}

function formAnOceanWaveWords(move, pvs, dialect) {
  var [pass_through, diag, bal, center, center_hand, sides, beats] = pvs
  var [
    spass_through,
    sdiag,
    sbal,
    scenter,
    scenter_hand,
    ssides,
    sbeats,
  ] = parameter_strings(move, pvs, dialect)
  var ocean_wave = moveSubstitutionWithoutForm(move, dialect, false)
  var diagonal_ocean_wave = words(sdiag, ocean_wave)
  var a_diagonal_ocean_wave = words(
    indefiniteArticleFor(diagonal_ocean_wave),
    diagonal_ocean_wave
  )
  var tbal = bal ? ("*" === bal ? "& maybe balance" : "& balance") : ""
  var sside_hand =
    "*" === center_hand ? "opposite" : stringParamHand(!center_hand)
  if (pass_through !== true) {
    // false or '*'
    var form_an_ocean_wave = moveSubstitution(move, dialect)
    var substitution_starts_with_form = /^ *form/.test(form_an_ocean_wave)
    var form_a_diagonal_ocean_wave = words(
      substitution_starts_with_form && "form",
      a_diagonal_ocean_wave
    )
    var tmove =
      pass_through === "*"
        ? words("*", a_diagonal_ocean_wave)
        : form_a_diagonal_ocean_wave
    return words(
      tmove,
      tbal,
      "-",
      scenter,
      "by",
      scenter_hand,
      "hands and",
      ssides,
      "by",
      sside_hand,
      "hands"
    )
  } else {
    return words(
      "pass through to",
      a_diagonal_ocean_wave,
      tbal,
      "-",
      scenter,
      "by",
      scenter_hand,
      "in the center,",
      ssides,
      "by",
      sside_hand,
      "on the sides"
    )
  }
}

defineFigure(
  "form an ocean wave",
  [
    param("pass_through_true"),
    param("set_direction_acrossish"),
    param("balance_false"),
    param("center_pair_ladles"),
    param("by_xhand"),
    param("sides_pairs_neighbors"),
    param("beats_4"),
  ],
  {
    words: formAnOceanWaveWords,
    change: formAnOceanWaveChange,
    goodBeats: formAnOceanWaveGoodBeats,
  }
)

defineRelatedMove2Way("form an ocean wave", "form long waves")
defineRelatedMove2Way("form an ocean wave", "form a long wave")

////////////////////////////////////////////////
// GATE                                       //
////////////////////////////////////////////////

function gateWords(move, pvs, dialect) {
  var [subject, object, gate_face, beats] = pvs
  var [ssubject, sobject, sgate_face, sbeats] = parameter_strings(
    move,
    pvs,
    dialect
  )
  var smove = moveSubstitution(move, dialect)
  return words(ssubject, smove, sobject, "to face", sgate_face)
}

// 'ones gate twos' means: ones, extend a hand to twos - twos walk
// forward, ones back up, orbiting around the joined hands
defineFigure(
  "gate",
  [
    param("subject_pair"),
    param("object_pairs_or_ones_or_twos"),
    param("gate_face"),
    param("beats_8"),
  ],
  { words: gateWords }
)

////////////////////////////////////////////////
// GIVE AND TAKE                              //
////////////////////////////////////////////////

function giveAndTakeChange(figure, index) {
  var pvs = figure.parameter_values
  var [who, whom, give, beats] = pvs
  var give_idx = 2
  var beats_idx = 3
  if (give && beats === 4 && index === give_idx) {
    pvs[beats_idx] = 8
  } else if (!give && beats === 8 && index === give_idx) {
    pvs[beats_idx] = 4
  }
}

function giveAndTakeGoodBeats(figure) {
  var [who, whom, give, beats] = figure.parameter_values
  if (give) {
    return 4 <= beats && beats <= 8
  } else {
    return 2 <= beats && beats <= 4
  }
}

function giveAndTakeWords(move, pvs, dialect) {
  var [who, whom, give, beats] = pvs
  var [swho, swhom, sgive, sbeats] = parameter_strings(move, pvs, dialect)
  var smove = give
    ? give === "*"
      ? "give? & take"
      : moveSubstitution(move, dialect)
    : "take"
  return words(swho, smove, swhom)
}

defineFigure(
  "give & take",
  [
    param("subject_role_gentlespoons"),
    param("object_hetero_partners"),
    param("give"),
    param("beats_8"),
  ],
  {
    words: giveAndTakeWords,
    change: giveAndTakeChange,
    goodBeats: giveAndTakeGoodBeats,
  }
)

////////////////////////////////////////////////
// FACING STAR (formerly gyre star)           //
////////////////////////////////////////////////

function facingStarGoodBeats(figure) {
  var [who, turn, places, beats] = figure.parameter_values
  return 270 / 8 === places / beats // floating point division equality should be okay because it's power-of-2.
}

function facingStarWords(move, pvs, dialect) {
  var [who, turn, places, beats] = pvs
  var [swho, sturn, splaces, sbeats] = parameter_strings(move, pvs, dialect)
  var shand = turn ? ("*" === turn ? "*" : "left") : "right"
  var smove = moveSubstitution(move, dialect)
  return words(
    smove,
    sturn,
    splaces,
    "with",
    swho,
    "putting their",
    shand,
    "hands in and backing up"
  )
}

defineFigure(
  "facing star",
  [
    param("subject_pair"),
    param("spin_clockwise"),
    param("three_places"),
    param("beats_8"),
  ],
  { words: facingStarWords, goodBeats: facingStarGoodBeats }
)

defineRelatedMove2Way("facing star", "gyre")
defineRelatedMove2Way("facing star", "star")

////////////////////////////////////////////////
// GYRE                                       //
////////////////////////////////////////////////

function gyreSubstitutionPrintsRightShoulder(smove) {
  // print the right shoulder unless it's a single word starting with 'g', or it starts and ends with 'face'.
  // \S = non-whitespace
  return !(smove.match(/^g\S+$/i) || smove.match(/^face.*face$/i))
}

function gyreGoodBeats(figure) {
  var [who, shoulder, rots, beats] = figure.parameter_values
  var angle_over_beats = rots / beats
  return beats > 0 && 360 / 8 <= angle_over_beats && angle_over_beats <= 540 / 8
}

function gyreWords(move, pvs, dialect) {
  var [who, shoulders, rots, beats] = pvs
  var [swho, sshoulders, srots, sbeats] = parameter_strings(move, pvs, dialect)
  var smove = moveSubstitutionWithEscape(move, dialect)
  var leftShoulders = !shoulders
  if (smove.match(/%S/)) {
    var smoveExpansion = smove.replace(/%S/g, stringParamHand(shoulders))
    return words(swho, smoveExpansion, srots)
  } else {
    return words(swho, smove, leftShoulders && sshoulders, srots)
  }
}

defineFigure(
  "gyre",
  [
    param("subject_pairz"),
    param("right_shoulders_spin"),
    param("once_around"),
    param("beats_8"),
  ],
  { words: gyreWords, goodBeats: gyreGoodBeats }
)

////////////////////////////////////////////////
// HEY                                        //
////////////////////////////////////////////////

function heyChange(figure, index) {
  var pvs = figure.parameter_values
  var hey_length_idx = 3
  var beats_idx = 9
  var hey_length = pvs[hey_length_idx]
  if (hey_length_idx === index) {
    pvs[beats_idx] = heyLengthMeetTimes(hey_length) * 8
  }
}

function heyGoodBeats(figure) {
  var [
    who,
    who2,
    shoulder,
    hey_length,
    dir,
    rico1,
    rico2,
    rico3,
    rico4,
    beats,
  ] = figure.parameter_values
  var [duration_or_dancer, meet_times] = parseHeyLength(hey_length)
  if (
    -1 !==
    ["full", "between half and full", "half", "less than half"].indexOf(
      duration_or_dancer
    )
  ) {
    return beats === 8 * heyLengthMeetTimes(hey_length)
  } else {
    switch (meet_times) {
      case 1:
        return 0 <= beats && beats <= 8
      case 2:
        return 8 < beats && beats <= 16
      default:
        return false // should never happen so quietly freak out
    }
  }
}

function heyWords(move, pvs, dialect) {
  var [
    first_pass,
    second_pass,
    shoulder,
    hey_length,
    dir,
    rico1,
    rico2,
    rico3,
    rico4,
    beats,
  ] = pvs
  var [
    sfirst_pass,
    ssecond_pass,
    sshoulder,
    shey_length,
    sdir,
    srico1,
    srico2,
    srico3,
    srico4,
    sbeats,
  ] = parameter_strings(move, pvs, dialect)
  var smove = moveSubstitution(move, dialect)
  var any_ricochets = rico1 || rico2 || rico3 || rico4
  var center_pass
  var scenter_pass
  var error = ""
  if (dancerIsPair(first_pass)) {
    center_pass = first_pass
    scenter_pass = sfirst_pass
    if (dancerIsPair(second_pass)) {
      error = "exactly one pass should be a single pair of dancers"
    }
  } else if (dancerIsPair(second_pass)) {
    center_pass = second_pass
    scenter_pass = ssecond_pass
  } else if ("*" === first_pass) {
    center_pass = first_pass
    scenter_pass = sfirst_pass
  } else if ("*" === second_pass) {
    center_pass = second_pass
    scenter_pass = second_pass
  } else if (any_ricochets && !second_pass) {
    center_pass = null
    scenter_pass = "____"
    error = "specify second pass"
  } else if (any_ricochets) {
    center_pass = null
    scenter_pass = "____"
    error = "exactly one pass should be a single pair of dancers"
  }
  var sdir2 = dir === "across" ? "" : sdir
  var uses_until = !(
    hey_length === "full" ||
    hey_length === "half" ||
    hey_length === null ||
    hey_length == "*"
  )
  var main_move_phrase = uses_until
    ? words(sdir2, smove)
    : words(sdir2, shey_length, smove)
  var other_sshoulder = stringParamShouldersTerse(
    "*" === shoulder || null === shoulder ? shoulder : !shoulder
  )
  var first_pass_is_pair = dancerIsPair(first_pass)
  var first_shoulder_place = !first_pass_is_pair ? "on ends" : "in center"
  var second_shoulder_place = first_pass_is_pair ? "on ends" : "in center"
  var rico_string = ""
  if (any_ricochets) {
    var ricos = [rico1, rico2, rico3, rico4]
    var rico_strings = []
    for (var i = 0; i < ricos.length; i++) {
      if (ricos[i]) {
        var who =
          i & 1 && center_pass != "*"
            ? invertPair(center_pass, dialect)
            : scenter_pass
        var time =
          hey_length === "half" ? "" : i & 2 ? " second time" : " first time"
        if (ricos[i] !== "*") {
          rico_strings.push(who + " ricochet" + time)
        } else {
          rico_strings.push(who + " maybe ricochet" + time)
        }
      }
    }
    rico_string = " - " + rico_strings.join(", ")
  }
  return words(
    error && "Error (" + error + ") -",
    sfirst_pass,
    "start",
    indefiniteArticleFor(main_move_phrase),
    main_move_phrase,
    "-",
    sshoulder,
    first_shoulder_place,
    comma,
    other_sshoulder,
    second_shoulder_place,
    uses_until && "-",
    uses_until && shey_length,
    rico_string
  )
}

// so either the first pairz or the second will be a pair. If it's not, it's an error in dance entry.

defineFigure(
  "hey",
  [
    param("subject_pairz_ladles"),
    param("subject2_pairz_or_unspecified"),
    param("rights_spin"),
    param("hey_length_half"),
    param("set_direction_across"),
    param("ricochet1_false"),
    param("ricochet2_false"),
    param("ricochet3_false"),
    param("ricochet4_false"),
    param("beats_8"),
  ],
  {
    words: heyWords,
    change: heyChange,
    goodBeats: heyGoodBeats,
    labels: ["pass1", "pass2", , , , "rico1", "rico2", "rico3", "rico4"],
  }
)

////////////////////////////////////////////////
// LONG LINES                                 //
////////////////////////////////////////////////

function longLinesChange(figure, index) {
  var pvs = figure.parameter_values
  const back_index = 0
  const beats_index = 1
  if (index === back_index) {
    pvs[beats_index] = pvs[back_index] ? 8 : 4
  }
}

function longLinesGoodBeats(figure) {
  var [back, beats] = figure.parameter_values
  return beats === (back ? 8 : 4)
}

function longLinesWords(move, pvs, dialect) {
  var [back, beats] = pvs
  var [sback, sbeats] = parameter_strings(move, pvs, dialect)
  var smove = moveSubstitution(move, dialect)
  var directions = back
    ? back === "*"
      ? "forward & maybe back"
      : "forward & back"
    : "forward"
  return words(smove, directions)
}

defineFigure("long lines", [param("go_back"), param("beats_8")], {
  words: longLinesWords,
  change: longLinesChange,
  goodBeats: longLinesGoodBeats,
})

////////////////////////////////////////////////
// MAD ROBIN                                  //
////////////////////////////////////////////////

function madRobinGoodBeats(figure) {
  var [role, angle, beats] = figure.parameter_values
  if (0 === beats) {
    return false
  }
  var angle_per_beat = angle / beats
  return 360 / 8 <= angle_per_beat && angle_per_beat <= 360 / 6
}

function madRobinWords(move, pvs, dialect) {
  var [role, angle, beats] = pvs
  var [srole, sangle, sbeats] = parameter_strings(move, pvs, dialect)
  var smove = moveSubstitution(move, dialect)
  var tangle = angle !== 360 && sangle + " around"
  return words(smove, tangle, comma, srole, "in front")
}

defineFigure(
  "mad robin",
  [param("subject_pair"), param("once_around"), param("beats_6")],
  { words: madRobinWords, goodBeats: madRobinGoodBeats }
)

////////////////////////////////////////////////
// PASS BY                                    //
////////////////////////////////////////////////

defineFigure("pass by", [
  param("subject_pairz"),
  param("right_shoulders_spin"),
  param("beats_2"),
])

defineRelatedMove2Way("pass by", "hey")
defineRelatedMove2Way("pass by", "half hey")

////////////////////////////////////////////////
// PASS THROUGH                               //
////////////////////////////////////////////////

function passThroughWords(move, pvs, dialect) {
  var [dir, spin, beats] = pvs
  var [sdir, sspin, sbeats] = parameter_strings(move, pvs, dialect)
  var smove = moveSubstitution(move, dialect)
  var left_shoulder_maybe = spin && spin !== "*" ? "" : sspin
  return words(smove, left_shoulder_maybe, sdir)
}

defineFigure(
  "pass through",
  [
    param("set_direction_along"),
    param("right_shoulders_spin"),
    param("beats_2"),
  ],
  { words: passThroughWords }
)

defineRelatedMove2Way("pass by", "pass through")

////////////////////////////////////////////////
// PETRONELLA                                 //
////////////////////////////////////////////////

function petronellaGoodBeats(figure) {
  var [balance, beats] = figure.parameter_values
  return beats === (balance ? 8 : 4)
}

function petronellaWords(move, pvs, dialect) {
  var [balance, beats] = pvs
  var [sbalance, sbeats] = parameter_strings(move, pvs, dialect)
  var smove = moveSubstitution(move, dialect)
  return words(sbalance, smove)
}

defineFigure("petronella", [param("balance_true"), param("beats_8")], {
  words: petronellaWords,
  goodBeats: petronellaGoodBeats,
})

////////////////////////////////////////////////
// POUSSETTE                                  //
////////////////////////////////////////////////

function poussetteGoodBeats(figure) {
  var [half_or_full, who, whom, turn, beats] = figure.parameter_values
  var beats_per_half_poussette = beats / (2 * half_or_full)
  return 6 <= beats_per_half_poussette && beats_per_half_poussette <= 8
}

function poussetteWords(move, pvs, dialect) {
  var [half_or_full, who, whom, turn, beats] = pvs
  var [shalf_or_full, swho, swhom, sturn, sbeats] = parameter_strings(
    move,
    pvs,
    dialect
  )
  var smove = moveSubstitution(move, dialect)
  var tturn
  if (undefined === turn) {
    tturn = "____"
  } else if ("*" === turn) {
    tturn = "back then *"
  } else if (turn) {
    tturn = "back then left"
  } else {
    tturn = "back then right"
  }
  return words(shalf_or_full, smove, "-", swho, "pull", swhom, tturn)
}

defineFigure(
  "poussette",
  [
    param("half_or_full_half_chatty_max"),
    param("subject_pair"),
    param("object_pairs_or_ones_or_twos"),
    param("spin"),
    param("beats_6"),
  ],
  { words: poussetteWords, goodBeats: poussetteGoodBeats }
)

////////////////////////////////////////////////
// PROMENADE                                  //
////////////////////////////////////////////////

function promenadeWords(move, pvs, dialect) {
  var [subject, dir, spin, beats] = pvs
  var [ssubject, sdir, sspin, sbeats] = parameter_strings(move, pvs, dialect)
  var smove = moveSubstitution(move, dialect)
  var tspin = spin
    ? spin === "*"
      ? "on the *"
      : "on the left"
    : dir === "along"
    ? "on the right"
    : ""
  return words(ssubject, smove, sdir, tspin)
}

defineFigure(
  "promenade",
  [
    param("subject_pairs_partners"),
    param("set_direction_across"),
    param("spin_right"),
    param("beats_8"),
  ],
  { words: promenadeWords, labels: [, , "keep"] }
)

////////////////////////////////////////////////
// PULL BY DANCERS                            //
////////////////////////////////////////////////

function pullByDancersGoodBeats(figure) {
  var [who, bal, spin, beats] = figure.parameter_values
  var b = beats - (bal ? 4 : 0)
  return 0 < b && b <= 4
}

function pullByDancersWords(move, pvs, dialect) {
  var [who, bal, spin, beats] = pvs
  var [swho, sbal, sspin, sbeats] = parameter_strings(move, pvs, dialect)
  var pmove = moveSubstitution(move, dialect)
  var smove = pmove === move ? "pull by" : pmove
  return words(swho, sbal, smove, sspin)
}

function pullByDancersChange(figure, index) {
  var pvs = figure.parameter_values
  var [who, bal, spin, beats] = pvs
  var balance_idx = 1
  var beats_idx = 3
  //modify beats to match whether balance checkbox is checked
  if (bal && beats === 2 && index === balance_idx) {
    pvs[beats_idx] = 8
  } else if (!bal && index === balance_idx) {
    pvs[beats_idx] = 2
  }
}

defineFigure(
  "pull by dancers",
  [
    param("subject_pairz"),
    param("balance_false"),
    param("right_hand_spin"),
    param("beats_2"),
  ],
  {
    change: pullByDancersChange,
    goodBeats: pullByDancersGoodBeats,
    words: pullByDancersWords,
  }
)

////////////////////////////////////////////////
// PULL BY DIRECTION                          //
////////////////////////////////////////////////

function pullByDirectionGoodBeats(figure) {
  var [bal, dir, spin, beats] = figure.parameter_values
  return beats === (bal ? 8 : 2)
}

function pullByDirectionWords(move, pvs, dialect) {
  var [bal, dir, spin, beats] = pvs
  var [sbal, sdir, sspin, sbeats] = parameter_strings(move, pvs, dialect)
  var pmove = moveSubstitution(move, dialect)
  var smove = pmove === move ? "pull by" : pmove
  var is_diagonal = dir === "left diagonal" || dir === "right diagonal"
  if (!is_diagonal) {
    return words(sbal, smove, sspin, sdir)
  } else if (("right diagonal" === dir) === spin) {
    return words(sbal, smove, sdir) // "pull by left diagonal" left hand is implicit - this makes XYZ a non-mouthful
  } else {
    return words(sbal, smove, sspin, "hand", dir) // "pull by left hand right diagonal" - this deserves to be a mouthful
  }
}

function pullByDirectionChange(figure, index) {
  var pvs = figure.parameter_values
  var [bal, dir, spin, beats] = pvs
  var balance_idx = 0
  var beats_idx = 3
  //modify beats to match whether balance checkbox is checked
  if (bal && beats === 2 && index === balance_idx) {
    pvs[beats_idx] = 8
  } else if (!bal && index === balance_idx) {
    pvs[beats_idx] = 2
  }
}

defineFigure(
  "pull by direction",
  [
    param("balance_false"),
    param("set_direction_along"),
    param("right_hand_spin"),
    param("beats_2"),
  ],
  {
    change: pullByDirectionChange,
    goodBeats: pullByDirectionGoodBeats,
    words: pullByDirectionWords,
  }
)

defineRelatedMove2Way("pull by dancers", "pull by direction")

////////////////////////////////////////////////
// REVOLVING DOOR                             //
////////////////////////////////////////////////

function revolvingDoorWords(move, pvs, dialect) {
  var [subject, hand, object, beats] = pvs
  var [ssubject, shand, sobject, sbeats] = parameter_strings(move, pvs, dialect)
  var smove = moveSubstitution(move, dialect)
  var thand = hand === "*" ? "*" : shand
  return words(
    smove,
    " - ",
    ssubject,
    "take",
    thand,
    "hands and drop off",
    sobject,
    "on other side"
  )
}

defineFigure(
  "revolving door",
  [
    param("subject_pair"),
    param("left_hand_spin"),
    param("object_pairs"),
    param("beats_8"),
  ],
  { words: revolvingDoorWords }
)

////////////////////////////////////////////////
// RIGHT LEFT THROUGH                         //
////////////////////////////////////////////////

function rightLeftThroughWords(move, pvs, dialect) {
  var [diag, beats] = pvs
  var [sdiag, sbeats] = parameter_strings(move, pvs, dialect)
  var smove = moveSubstitution(move, dialect)
  return words(sdiag, smove)
}

defineFigure(
  "right left through",
  [param("set_direction_across"), param("beats_8")],
  { words: rightLeftThroughWords }
)

////////////////////////////////////////////////
// ROLL AWAY                                  //
////////////////////////////////////////////////

defineFigure("roll away", [
  param("subject_pair"),
  param("object_pairs_or_ones_or_twos"),
  param("half_sashay_false"),
  param("beats_4"),
])

////////////////////////////////////////////////
// RORY O'MORE                                //
////////////////////////////////////////////////

function roryOMoreChange(figure, index) {
  var pvs = figure.parameter_values
  const bal_index = 1
  const beats_index = 3
  if (index === bal_index) {
    pvs[beats_index] = pvs[bal_index] ? 8 : 4
  }
}

function roryOMoreGoodBeats(figure) {
  var [who, balance, dir, beats] = figure.parameter_values
  return beats === (balance ? 8 : 4)
}

function roryOMoreWords(move, pvs, dialect) {
  var [who, balance, dir, beats] = pvs
  var [swho, sbalance, sdir, sbeats] = parameter_strings(move, pvs, dialect)
  var smove = moveSubstitution(move, dialect)
  var swho2 = who === "everyone" ? "" : swho
  return words(sbalance, swho2, smove, sdir)
}

defineFigure(
  "Rory O'More",
  [
    param("subject_pairc_or_everyone"),
    param("balance_true"),
    param("slide_right"),
    param("beats_8"),
  ],
  {
    words: roryOMoreWords,
    change: roryOMoreChange,
    goodBeats: roryOMoreGoodBeats,
  }
)

////////////////////////////////////////////////
// SLICE                                      //
////////////////////////////////////////////////

function sliceChange(figure, index) {
  var pvs = figure.parameter_values
  var [dir, increment, rtrn, beats] = pvs
  const rtrn_index = 2
  const beats_index = 3
  if (index === rtrn_index) {
    var none = rtrn === "none"
    if (none && beats === 8) {
      pvs[beats_index] = 4
    } else if (!none && beats === 4) {
      pvs[beats_index] = 8
    }
  }
}

function sliceGoodBeats(figure) {
  var [dir, increment, rtrn, beats] = figure.parameter_values
  var no_return = rtrn === "none"
  return beats === (no_return ? 4 : 8)
}

defineFigure(
  "slice",
  [
    param("slide_left"),
    param("slice_increment"),
    param("slice_return"),
    param("beats_8"),
  ],
  {
    labels: ["slice", "by", "return"],
    change: sliceChange,
    goodBeats: sliceGoodBeats,
  }
)

////////////////////////////////////////////////
// SLIDE ALONG SET -- progression, couples    //
////////////////////////////////////////////////

function slideAlongSetWords(move, pvs, dialect) {
  var [dir, beats] = pvs
  var [sdir, sbeats] = parameter_strings(move, pvs, dialect)
  return words("slide", sdir, "along set")
}

defineFigure("slide along set", [param("slide_left"), param("beats_2")], {
  words: slideAlongSetWords,
})

////////////////////////////////////////////////
// SQUARE THROUGH                             //
////////////////////////////////////////////////

function squareThroughChange(figure, index) {
  squareThroughChangeSubjects(figure, index)
  squareThroughChangeBeats(figure, index)
}

function squareThroughChangeSubjects(figure, index) {
  const pvs = figure.parameter_values
  const invert = { partners: "neighbors", neighbors: "partners" }
  const who1 = 0
  const who2 = 1
  if (index === who1 && (pvs[who2] === pvs[who1] || pvs[who2] === undefined)) {
    pvs[who2] = invert[pvs[who1]]
  } else if (
    index === who2 &&
    (pvs[who1] == pvs[who2] || pvs[who1] === undefined)
  ) {
    pvs[who1] = invert[pvs[who2]]
  }
}

function squareThroughChangeBeats(figure, index) {
  const beats_idx = 5
  const pvs = figure.parameter_values

  const balance_idx = 2
  const angle_idx = 4
  const changed_balance_or_places = index === balance_idx || index === angle_idx
  if (changed_balance_or_places) {
    pvs[beats_idx] = squareThroughExpectedBeats(pvs)
  }
}

function squareThroughGoodBeats(figure) {
  var pvs = figure.parameter_values
  var beats = pvs[5]
  return squareThroughExpectedBeats(pvs) === beats
}

function squareThroughExpectedBeats(pvs) {
  const balance_idx = 2
  const angle_idx = 4

  const angle = pvs[angle_idx]
  const places = "*" === angle ? "*" : angle / 90
  if ([2, 3, 4, "*"].indexOf(places) < 0) {
    throw_up("unexpected number of places to squareThroughExpectedBeats")
  }
  const balance_beats = ((places + 1) >> 1) * 4 * pvs[balance_idx]
  const pull_by_beats = places * 2
  return balance_beats + pull_by_beats
}

function squareThroughWords(move, pvs, dialect) {
  var [subject1, subject2, bal, hand, angle, beats] = pvs
  var [ssubject1, ssubject2, sbal, shand, sangle, sbeats] = parameter_strings(
    move,
    pvs,
    dialect
  )
  var smove = moveSubstitution(move, dialect)
  var shand2 = hand ? ("*" === hand ? "*" : "left") : "right"
  var places = "*" === angle ? "*" : angle / 90
  var placewords =
    { 2: "two", 3: "three", 4: "four", "*": "*" }[places] ||
    throw_up("unexpected number of places to squareThroughWords")

  if (3 === places) {
    return words(
      smove,
      placewords,
      "-",
      ssubject1,
      sbal,
      "pull by",
      shand,
      comma,
      "then",
      ssubject2,
      "pull by",
      shand2,
      comma,
      "then",
      ssubject1,
      sbal,
      "pull by",
      shand
    )
  } else {
    var yadda_text = { 2: false, 4: "then repeat", "*": "yadda yadda yadda" }[
      places
    ]
    return words(
      smove,
      placewords,
      "-",
      ssubject1,
      sbal,
      "pull by",
      shand,
      comma,
      "then",
      ssubject2,
      "pull by",
      shand2,
      yadda_text && comma,
      yadda_text
    )
  }
}

defineFigure(
  "square through",
  [
    param("subject_pairs"),
    param("subject2_pairs"),
    param("balance_true"),
    param("right_hand_spin"),
    param("four_places"),
    param("beats_16"),
  ],
  {
    words: squareThroughWords,
    change: squareThroughChange,
    labels: [, , "odd bal"],
    goodBeats: squareThroughGoodBeats,
  }
)

////////////////////////////////////////////////
// STAND STILL                                //
////////////////////////////////////////////////

defineFigure("stand still", [param("beats_8")], {
  goodBeats: goodBeatsMinFn(1),
})

////////////////////////////////////////////////
// STAR                                       //
////////////////////////////////////////////////

function starGoodBeats(figure) {
  var [right_hand, angle, wrist_grip, beats] = figure.parameter_values
  var three_places_in_about_eight_beats =
    angle === 270 && 6 <= beats && beats <= 8
  var one_place_per_two_beats = angle / beats === 45
  return three_places_in_about_eight_beats || one_place_per_two_beats
}

function starWords(move, pvs, dialect) {
  var [right_hand, places, wrist_grip, beats] = pvs
  var [sright_hand, splaces, swrist_grip, sbeats] = parameter_strings(
    move,
    pvs,
    dialect
  )
  var smove = moveSubstitution(move, dialect)
  if ("" === wrist_grip) {
    return words(smove, sright_hand, splaces)
  } else {
    return words(smove, sright_hand, "-", swrist_grip, "-", splaces)
  }
}

defineFigure(
  "star",
  [
    param("xhand_spin"),
    param("four_places"),
    param("star_grip"),
    param("beats_8"),
  ],
  { words: starWords, goodBeats: starGoodBeats }
)

////////////////////////////////////////////////
// STAR PROMENADE                             //
////////////////////////////////////////////////

function starPromenadeGoodBeats(figure) {
  var [who, dir, angle, beats] = figure.parameter_values
  return 180 / 4 === angle / beats
}

function starPromenadeWords(move, pvs, dialect) {
  var [who, dir, angle, beats] = pvs
  var [swho, sdir, sangle, sbeats] = parameter_strings(move, pvs, dialect)
  var smove = moveSubstitution(move, dialect)
  return words(who != "gentlespoons" && swho, smove, sdir, sangle)
}

defineFigure(
  "star promenade",
  [
    param("subject_pair_gentlespoons"),
    param("xhand_spin"),
    param("half_around"),
    param("beats_4"),
  ],
  { words: starPromenadeWords, goodBeats: starPromenadeGoodBeats }
)

defineRelatedMove2Way("star promenade", "allemande")
defineRelatedMove2Way("star promenade", "promenade")
defineRelatedMove2Way("star promenade", "butterfly whirl")

///////////////////////////////////////////////
// SWING                                      //
////////////////////////////////////////////////

function swingAlias(figure) {
  var [who, prefix, beats] = figure.parameter_values
  return prefix === "meltdown" ? "meltdown swing" : "swing"
}

function swingChange(figure, index) {
  var pvs = figure.parameter_values
  var [who, prefix, beats] = pvs
  const prefix_idx = 1
  const beats_idx = 2
  if (prefix !== "none" && index === prefix_idx && beats <= 8) {
    beats = figure.parameter_values[beats_idx] = 16
  }
}

function swingGoodBeats(figure) {
  var pvs = figure.parameter_values
  var [who, prefix, beats] = pvs
  if ("none" === prefix) {
    return 8 <= beats && beats <= 16
  } else {
    return 14 <= beats && beats <= 16
  }
}

function swingWords(move, pvs, dialect) {
  var [who, prefix, beats] = pvs
  var [swho, sprefix, sbeats] = parameter_strings(move, pvs, dialect)
  var no_prefix = prefix === "none"
  var bprefix = prefix === "balance" ? "balance &" : prefix === "*" ? "*" : ""
  var smove = moveSubstitution(move, dialect)
  var slong = beats === 16 && no_prefix ? "long" : ""
  return words(swho, bprefix, slong, smove)
}

defineFigure(
  "swing",
  [
    param("subject_pairz_partners"),
    param("swing_prefix_none"),
    param("beats_8"),
  ],
  {
    change: swingChange,
    words: swingWords,
    alias: swingAlias,
    goodBeats: swingGoodBeats,
    alignBeatsEnd: 16,
  }
)

defineFigureAlias("meltdown swing", "swing", [
  null,
  param("swing_prefix_meltdown"),
  null,
])

///////////////////////////////////////////////
// TURN ALONE                                //
///////////////////////////////////////////////

function turnAloneWords(move, pvs, dialect) {
  var [who, custom, beats] = pvs
  var [swho, scustom, sbeats] = parameter_words(move, pvs, dialect)
  var smove = moveSubstitution(move, dialect)
  return words("everyone" !== who && swho, smove, scustom)
}

defineFigure(
  "turn alone",
  [param("subject_pair_or_everyone"), param("custom_figure"), param("beats_4")],
  { words: turnAloneWords, goodBeats: goodBeatsMinMaxFn(0, 4) }
)

///////////////////////////////////////////////
// ZIG ZAG                                    //
////////////////////////////////////////////////

function zigZagWords(move, pvs, dialect) {
  var [who, spin, ender, beats] = pvs
  var [swho, sspin, sender, sbeats] = parameter_strings(move, pvs, dialect)
  // var smove = moveSubstitution(move, dialect);
  var comma_maybe = ender === "allemande" && comma
  var return_sspin = spin ? ("*" === spin ? "*" : "right") : "left"
  var twho = who === "partners" ? "" : swho
  return words(twho, "zig", sspin, "zag", return_sspin, comma_maybe, sender)
}

defineFigure(
  "zig zag",
  [
    param("subject_pairs_partners"),
    param("spin_left"),
    param("zig_zag_ender"),
    param("beats_6"),
  ],
  { words: zigZagWords }
)
