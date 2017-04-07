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

var defined_choosers = {}


function defineChooser(name){
    "string" == typeof name || throw_up("first argument isn't a string")
    "chooser_" == name.slice(0,8) || throw_up("first argument doesn't begin with 'chooser_'")
    defined_choosers[name] = defined_choosers[name] || name
    eval(name+"='"+name+"'")
}
function setChoosers(hash){
    $.each(defined_choosers,function(k,v){hash[k]=v})
}

defineChooser("chooser_boolean")
defineChooser("chooser_beats")
defineChooser("chooser_spin")
defineChooser("chooser_left_right_spin")
defineChooser("chooser_right_left_hand")
defineChooser("chooser_right_left_shoulder")
defineChooser("chooser_revolutions")
defineChooser("chooser_places")
defineChooser("chooser_dancers")  // some collection of dancers
defineChooser("chooser_pair")     // 1 pair of dancers
defineChooser("chooser_pairz")    // 1-2 pairs of dancers
defineChooser("chooser_pairs")    // 2 pairs of dancers
defineChooser("chooser_dancer")   // one dancer, e.g. ladle 1
defineChooser("chooser_role")     // ladles or gentlespoons
defineChooser("chooser_hetero")   // partners or neighbors or shadows
defineChooser("chooser_everyone_or_centers")
defineChooser("chooser_text")
defineChooser("chooser_star_grip")
defineChooser("chooser_facing")
defineChooser("chooser_slide")
defineChooser("chooser_set_direction")
defineChooser("chooser_slice_return")
defineChooser("chooser_slice_increment")
defineChooser("chooser_down_the_hall_ender")
