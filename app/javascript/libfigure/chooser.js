//        ____ _   _  ___   ___  ____  _____ ____
//       / ___| | | |/ _ \ / _ \/ ___|| ____|  _ \
//      | |   | |_| | | | | | | \___ \|  _| | |_) |
//      | |___|  _  | |_| | |_| |___) | |___|  _ <
//       \____|_| |_|\___/ \___/|____/|_____|_| \_\
//
//
// Choosers are UI elements without semantic ties to other choosers,
// who are given semantic ties by figures.
// So a figure could have two chooser_booleans
// or two chooser_dancers (e.g. GENTS roll away the NEIGHBORS)
// Choosers are obtained by calling, for example, `chooser('chooser_boolean')`
// You can read back a chooser's name property:
// `chooser('chooser_boolean').name => 'chooser_boolean'`
// Choosers can be compared with ===

var defined_choosers = {}

function defineChooser(name) {
  "string" == typeof name || throw_up("first argument isn't a string")
  "chooser_" == name.slice(0, 8) ||
    throw_up("first argument doesn't begin with 'chooser_'")
  defined_choosers[name] = { name: name }
}

export const chooser = name => {
  const chooser = defined_choosers[name]
  if (chooser) {
    return chooser
  } else {
    throw_up(JSON.stringify(name) + " is not the name of a chooser")
  }
}

defineChooser("chooser_boolean")
defineChooser("chooser_beats")
defineChooser("chooser_spin")
defineChooser("chooser_left_right_spin")
defineChooser("chooser_right_left_hand")
defineChooser("chooser_right_left_shoulder")
defineChooser("chooser_revolutions")
defineChooser("chooser_places")
defineChooser("chooser_text")
defineChooser("chooser_star_grip")
defineChooser("chooser_march_facing")
defineChooser("chooser_slide")
defineChooser("chooser_set_direction")
defineChooser("chooser_set_direction_acrossish")
defineChooser("chooser_set_direction_grid")
defineChooser("chooser_set_direction_figure_8")
defineChooser("chooser_gate_direction")
defineChooser("chooser_slice_return")
defineChooser("chooser_slice_increment")
defineChooser("chooser_down_the_hall_ender")
defineChooser("chooser_all_or_center_or_outsides")
defineChooser("chooser_zig_zag_ender")
defineChooser("chooser_go_back")
defineChooser("chooser_give")
defineChooser("chooser_half_or_full")
defineChooser("chooser_swing_prefix")
defineChooser("chooser_hey_length")

var _dancerMenuForChooser = {}

function defineDancerChooser(name, dancers) {
  defineChooser(name)
  _dancerMenuForChooser[name] = dancers
}

export const dancerMenuForChooser = function(chooser) {
  // chooser object
  return _dancerMenuForChooser[chooser.name]
}

function dancerCategoryMenuForChooser(chooser) {
  return libfigureUniq(dancerMenuForChooser(chooser).map(dancersCategory))
}

export const dancerChooserNames = function() {
  return Object.keys(_dancerMenuForChooser)
}

var outOfSetDancers = [
  "shadows",
  "2nd shadows",
  "prev neighbors",
  "next neighbors",
  "3rd neighbors",
  "4th neighbors",
]

defineDancerChooser(
  "chooser_dancers", // some collection of dancers
  [
    "everyone",
    "gentlespoon",
    "gentlespoons",
    "ladle",
    "ladles",
    "partners",
    "neighbors",
    "ones",
    "twos",
    "same roles",
    "first corners",
    "second corners",
    "first gentlespoon",
    "first ladle",
    "second gentlespoon",
    "second ladle",
  ].concat(outOfSetDancers)
)
defineDancerChooser(
  "chooser_pair", // 1 pair of dancers
  ["gentlespoons", "ladles", "ones", "twos", "first corners", "second corners"]
)
defineDancerChooser(
  "chooser_pair_or_everyone", // 1 pair or everyone
  ["everyone"].concat(dancerMenuForChooser(chooser("chooser_pair")))
)
defineDancerChooser(
  "chooser_pairc_or_everyone", // 1 pair or centers or everyone
  [
    "everyone",
    "gentlespoons",
    "ladles",
    "centers",
    "ones",
    "twos",
    // intentionally omitting 'first corners' and 'second corners', because 'centers' is clearer
  ]
)
defineDancerChooser(
  "chooser_pairz", // 1-2 pairs of dancers
  [
    "gentlespoons",
    "ladles",
    "partners",
    "neighbors",
    "ones",
    "twos",
    "same roles",
    "first corners",
    "second corners",
  ].concat(outOfSetDancers)
)
defineDancerChooser(
  "chooser_pairz_or_unspecified",
  [""].concat(dancerMenuForChooser(chooser("chooser_pairz")))
)
defineDancerChooser(
  "chooser_pairs", // 2 pairs of dancers
  ["partners", "neighbors", "same roles"].concat(outOfSetDancers)
)
defineDancerChooser(
  "chooser_pairs_or_ones_or_twos",
  ["partners", "neighbors", "same roles", "ones", "twos"].concat(
    outOfSetDancers
  )
)
defineDancerChooser(
  "chooser_pairs_or_everyone",
  ["everyone"].concat(dancerMenuForChooser(chooser("chooser_pairs")))
)
defineDancerChooser(
  "chooser_dancer", // one dancer
  ["first gentlespoon", "first ladle", "second gentlespoon", "second ladle"]
)
defineDancerChooser(
  "chooser_role", // ladles or gentlespoons
  ["gentlespoons", "ladles"]
)
defineDancerChooser(
  "chooser_hetero", // partners or neighbors or shadows but not same-role
  ["partners", "neighbors"].concat(outOfSetDancers)
)

// nb: this hash is also accessed from ruby.
var dancersCategoryHash = {
  // '1st shadows': 'shadows', // not sure if this needs to be included or not - for now: no
  "2nd shadows": "shadows",
  "prev neighbors": "neighbors",
  "next neighbors": "neighbors",
  // '2nd neighbors': 'neighbors', // not sure if this needs to be included or not - for now: no
  "3rd neighbors": "neighbors",
  "4th neighbors": "neighbors",
}

function dancersCategory(chooser) {
  return dancersCategoryHash[chooser] || chooser
}

export const dancers = function() {
  return dancerMenuForChooser(chooser("chooser_dancers"))
}

var heyLengthMenu = (function() {
  var pairz = dancerMenuForChooser(chooser("chooser_pairz"))
  var acc = ["full", "half"]
  for (var i = 0; i < pairz.length; i++) {
    acc.push(pairz[i] + "%%1")
    acc.push(pairz[i] + "%%2")
  }
  return acc
})()
