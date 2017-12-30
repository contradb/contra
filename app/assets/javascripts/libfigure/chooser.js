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
// Choosers are referenced by global variables, e.g. chooser_boolean evaluates to a chooser object. 
// Choosers can be compared with == in this file and in angular controller scopey thing.
// They are basically a big enum with all the functionality in a giant case statement in dances/_form.erb
// They also have to define dance filter UI in app/assets/javascripts/welcome.js

var defined_choosers = {};

function defineChooser(name){
  "string" == typeof name || throw_up("first argument isn't a string");
  "chooser_" == name.slice(0,8) || throw_up("first argument doesn't begin with 'chooser_'");
  defined_choosers[name] = defined_choosers[name] || name;
  eval(name+"='"+name+"'");
}

function setChoosers(hash){
  Object.keys(defined_choosers).forEach(function(key) {
    hash[key] = defined_choosers[key];
  });
}

defineChooser("chooser_boolean");
defineChooser("chooser_beats");
defineChooser("chooser_spin");
defineChooser("chooser_left_right_spin");
defineChooser("chooser_right_left_hand");
defineChooser("chooser_right_left_shoulder");
defineChooser("chooser_revolutions");
defineChooser("chooser_places");
defineChooser("chooser_dancers");  // some collection of dancers
defineChooser("chooser_pair");     // 1 pair of dancers
defineChooser("chooser_pair_or_everyone"); // 1 pair or everyone
defineChooser("chooser_pairc_or_everyone"); // 1 pair or centers or everyone
defineChooser("chooser_pairz");    // 1-2 pairs of dancers
defineChooser("chooser_pairs");    // 2 pairs of dancers
defineChooser("chooser_pairs_or_ones_or_twos");
defineChooser("chooser_pairs_or_everyone");
defineChooser("chooser_dancer");   // one dancer, e.g. ladle 1
defineChooser("chooser_role");     // ladles or gentlespoons
defineChooser("chooser_hetero");   // partners or neighbors or shadows
defineChooser("chooser_text");
defineChooser("chooser_star_grip");
defineChooser("chooser_march_facing");
defineChooser("chooser_slide");
defineChooser("chooser_set_direction");
defineChooser("chooser_set_direction_grid");
defineChooser("chooser_gate_direction");
defineChooser("chooser_slice_return");
defineChooser("chooser_slice_increment");
defineChooser("chooser_down_the_hall_ender");
defineChooser("chooser_zig_zag_ender");
defineChooser("chooser_go_back");
defineChooser("chooser_give");
defineChooser("chooser_half_or_full");

var dancersCategory = {
  everyone: 'everyone',
  gentlespoons: 'gentlespoons',
  ladles: 'ladles',
  partners: 'partners',
  neighbors: 'neighbors',
  ones: 'ones',
  twos: 'twos',
  'same roles': 'same roles',
  'first corners': 'first corners',
  'second corners': 'second corners',
  'first gentlespoon': 'first gentlespoon',
  'first ladle': 'first ladle',
  'second gentlespoon': 'second gentlespoon',
  'second ladle': 'second ladle',
  shadows: 'shadows',
  // '1st shadows': 'shadows', // not sure if this needs to be included or not - for now: no
  '2nd shadows': 'shadows',
  'prev neighbors': 'neighbors',
  'next neighbors': 'neighbors',
  // '2nd neighbors': 'neighbors', // not sure if this needs to be included or not - for now: no
  '3rd neighbors': 'neighbors',
  '4th neighbors': 'neighbors'
};

// experiment
var pairz = [
  'gentlespoons',
  'ladles',
  'partners',
  'neighbors',
  'ones',
  'twos',
  'same roles',
  'first corners',
  'second corners',
  'shadows',
  '2nd shadows',
  'prev neighbors',
  'next neighbors',
  '3rd neighbors',
  '4th neighbors'
];

