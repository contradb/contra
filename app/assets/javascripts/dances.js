// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.


// take words, put them in strings, return a big, space separated string of them all. 
function words() {
    if (arguments.length <= 0) return "";
    else {
        var acc = arguments[0];
        var i;
        for (i=1; i<arguments.length; i++)
            acc += " " + arguments[i];
        return acc;
    }
}


var moveCaresAboutRotationsHash =
    {"do si do":  true
    ,"allemande": true
    ,"gyre":      true
    };
function moveCaresAboutRotations (move) {
    return moveCaresAboutRotationsHash[deAliasName(move)];
}

var moveCaresAboutPlacesHash = {circle: true, star: true};
function moveCaresAboutPlaces (move) {
    return moveCaresAboutPlacesHash[deAliasName(move)];
}

var degrees2rotations = { 90: "¼", 
                         180: "½", 
                         270: "¾",
                         360: "once around",
                         450: "1¼",
                         540: "1½",
                         630: "1¾",
                         720: "twice around"}
var degrees2places = { 90: "1 place", 
                      180: "2 places", 
                      270: "3 places",
                      360: "4 places",
                      450: "5 places",
                      540: "6 places",
                      630: "7 places",
                      720: "8 places"}
function degreesToWords (degrees,optional_move) {
    if (moveCaresAboutRotations(optional_move) && degrees2rotations[degrees]) 
        return degrees2rotations[degrees];
    else if (moveCaresAboutPlaces(optional_move) && degrees2places[degrees]) 
        return degrees2places[degrees];
    return degrees.toString();
}
function degreesToRotations(degrees) {
    return degrees2rotations[degrees] || (degrees.toString() + " degrees");
}
function degreesToPlaces(degrees) {
    return degrees2places[degrees] || (degrees.toString() + " degrees");
}

var anglesForMoveArr = [90,180,270,360,450,540,630,720];
function anglesForMove (move) {
    // move is intentionally ignored
    return anglesForMoveArr
}

// Patch to support current IE, source http://stackoverflow.com/questions/31720269/internet-explorer-11-object-doesnt-support-property-or-method-isinteger
isInteger = Number.isInteger || function(value) {
    return typeof value === "number" && 
           isFinite(value) && 
           Math.floor(value) === value;
};

function sumBeats(objs,optional_limit) {
    var acc = 0;
    var n = isInteger(optional_limit) ? optional_limit : objs.length;
    for (var i = 0; i < n; i++)
        acc += objs[i].beats;
    return acc;
}

function labelForBeats(beats) {
    if ((beats%16) == 0)
        switch (beats/16) {
        case 0: return "A1";
        case 1: return "A2";
        case 2: return "B1";
        case 3: return "B2";
    }
    return "";
}

function styleForBeats(beats) {
    return beats%32 < 16 ? 'a1b1' : 'a2b2' 
}


// always freshly allocated
function newFigure () {
    return { parameter_values: [] }
}

function defaultFigures (figures) {
    if (figures.length == 0)
        return [newFigure(), newFigure(), newFigure(), newFigure(),
                newFigure(), newFigure(), newFigure(), newFigure()]
    else return figures;
}


// =====================================================================================
// =====================================================================================

function figure_html_readonly(f) {
    var fig_def = defined_events[f.move];
    if (fig_def) {
        var func = fig_def.props.view || figure_html_readonly_default;
        return func(f.move, f.parameter_values)
    }
    else return "warning "+f.move;
}

function figure_html_readonly_default(move, parameter_values) {
    var ps = parameters(move);
    var acc = move;
    ps.length == parameter_values.length || throw_up("parameter type mismatch");
    for (var i=0; i < parameter_values.length; i++)
        acc += " " + String(parameter_values[i]);
    return acc;
}

// =====================================================================================

// throw is a keyword and can't be in expressions, but function calls can be, so wrap throw.
function throw_up(str) {
    throw new Error(str)
}

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

function moves(){
    var a = [];
    $.each(defined_events,function(k,v){a.push(k)})
    return a.sort();
}
var issued_parameter_warning = false
function parameters(fig_str){
    var fig = defined_events[fig_str];
    if (fig)
        return fig.parameters
    if (!issued_parameter_warning)
    {
        issued_parameter_warning = true
        console.log("Warning: could not find a figure definition for '"+fig_str+"', suppressing future warnings of this type");
    }
    return [];
}


var defined_choosers = {}

// Choosers are UI elements without semantic preconceptions, that work on dance elements.
// So a figure could have two chooser_booleans (obvious)
// or two chooser_dancers (e.g. GENTS roll away the NEIGHBORS)
// Choosers are referenced by global variables, e.g. chooser_boolean evaluates to a chooser object. 
// Choosers can be compared with == in this file and in angular controller scopey thing.
// They are basically a big enum with no functionality other than '==' at this time. 
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
defineChooser("chooser_side")
defineChooser("chooser_revolutions")
defineChooser("chooser_places")
defineChooser("chooser_dancers")  // some collection of dancers
defineChooser("chooser_pairz")    // 1-2 pairs of dancers
defineChooser("chooser_pairs")    // 2 pairs of dancers
defineChooser("chooser_dancer")   // one dancer, e.g. ladle 1
defineChooser("chooser_role")     // ladles or gentlespoons
defineChooser("chooser_hetero")   // partners or neighbors or shadows
defineChooser("chooser_text")

// Params have semantic value specific to each figure.
// Though some patterns have emerged. Patterns like:
// figures have a subject telling who's acted on by the figure. 
// 

param_balance_true = {name: "bal", value: true, ui: chooser_boolean}
param_balance_false = {name: "bal", value: false, ui: chooser_boolean}

param_beats_0 = {name: "beats", value: 0, ui: chooser_beats}
param_beats_2 = {name: "beats", value: 2, ui: chooser_beats}
param_beats_4 = {name: "beats", value: 4, ui: chooser_beats}
param_beats_6 = {name: "beats", value: 6, ui: chooser_beats}
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

param_by_side  = {name: "side",               ui: chooser_side} // promenades only, everything else uses a shoulder. Deprecate?
param_by_left  = {name: "side", value: true,  ui: chooser_side}
param_by_right = {name: "side", value: false, ui: chooser_side}

param_revolutions     = {name: "degrees",             ui: chooser_revolutions}
param_half_around     = {name: "degrees", value: 180, ui: chooser_revolutions}
param_once_around     = {name: "degrees", value: 360, ui: chooser_revolutions}
param_once_and_a_half = {name: "degrees", value: 540, ui: chooser_revolutions}
param_three_places    = {name: "degrees", value: 270, ui: chooser_places}
param_four_places     = {name: "degrees", value: 360, ui: chooser_places}

param_subject         = {name: "who", value: "everyone", ui: chooser_dancers}
param_subject_pairz   = {name: "who",                    ui: chooser_pairz} // 1-2 pairs of dancers
param_subject_pairs   = {name: "who",                    ui: chooser_pairs} // 2 pairs of dancers
param_subject_dancer  = {name: "who",                    ui: chooser_dancer}
param_subject_role_ladles       = {name: "who", value: "ladies",       ui: chooser_role}
param_subject_role_gentlespoons = {name: "who", value: "gentlespoons", ui: chooser_role}
param_subject_hetero           = {name: "who",                     ui: chooser_hetero}
param_subject_hetero_partners  = {name: "who", value: "partners",  ui: chooser_hetero}
param_subject_hetero_neighbors = {name: "who", value: "neighbors", ui: chooser_hetero}
param_subject_hetero_shadows   = {name: "who", value: "shadows",   ui: chooser_hetero}
param_subject_partners         = {name: "who", value: "partners",  ui: chooser_pairs} // allows more options if they
param_subject_neighbors        = {name: "who", value: "neighbors", ui: chooser_pairs} // don't go with default
param_subject_shadows          = {name: "who", value: "shadows",   ui: chooser_pairs} // than param_subject_hetero_*
// param_object_hetero           = {name: "whom", value: "partners",  ui: chooser_hetero} // not used yet

param_pass_on_left = {name: "pass", value: false, ui: chooser_right_left_shoulder}
param_pass_on_right = {name: "pass", value: true, ui: chooser_right_left_shoulder}

param_custom_figure = {name: "custom", value: "", ui: chooser_text}

defineFigure( "swing",                           [param_subject_pairz, param_balance_false, param_beats_8])
defineFigureAlias( "long swing",        "swing", [               null, param_balance_false, param_beats_16])
defineFigureAlias( "balance and swing", "swing", [               null, param_balance_true,  param_beats_16])

defineFigure( "allemande", [param_subject_pairz, param_xhand_spin, param_once_around, param_beats_8])
defineFigureAlias( "allemande left", "allemande", [null, param_left_hand_spin])
defineFigureAlias( "allemande right", "allemande", [null, param_right_hand_spin])

defineFigure( "do si do", [param_subject_pairz, param_right_shoulder_spin, param_once_around, param_beats_8])
defineFigureAlias( "see saw", "do si do", [null, param_left_shoulder_spin])

defineFigure( "gyre", [param_subject_pairz, param_right_shoulder_spin, param_once_around, param_beats_8])

defineFigure( "circle",                   [param_spin_left,  param_four_places, param_beats_8], {view: function(move,pvs) {return words("circle",pvs[0]?"left":"right",pvs[1]?degreesToWords(pvs[1],"circle"):"???","for",pvs[2]||"???")}})
defineFigureAlias( "circle three places", "circle", [param_spin_left,  param_three_places, param_beats_8])
defineFigureAlias( "circle right",        "circle", [param_spin_right, param_four_places, param_beats_8])

defineFigure( "long lines",               [param_beats_8])
defineFigure( "long lines forward only",  [param_beats_4])

defineFigure( "hey",                      [param_subject_role_ladles, param_beats_16])
defineFigure( "half hey",              [param_subject_role_ladles, param_beats_8])
defineFigureAlias( "hey halfway", "half hey", [])

defineFigure( "allemande orbit", [param_subject_role_ladles, param_left_hand_spin, param_once_and_a_half, param_half_around, param_beats_8])
defineFigure( "promenade across", [param_by_left, param_beats_8])

defineFigure( "custom", [param_custom_figure, param_beats_8])

;


// =====================================================================================


// =====================================================================================
// =====================================================================================






(function () {
    var app = angular.module('contra', []);
    var scopeInit = function ($scope) {
        var fctrl42 = this;
        $scope.moveCaresAboutRotations = moveCaresAboutRotations;
        $scope.moveCaresAboutPlaces = moveCaresAboutPlaces;
        $scope.degreesToWords = degreesToWords;
        $scope.anglesForMove = anglesForMove;
        $scope.sumBeats = sumBeats;
        $scope.labelForBeats = labelForBeats;
        $scope.styleForBeats = styleForBeats;

        $scope.moves = moves;
        $scope.parameters = parameters;
        $scope.degreesToRotations = degreesToRotations;
        $scope.degreesToPlaces = degreesToPlaces;
        setChoosers($scope);
        $scope.figure_html_readonly = figure_html_readonly

        $scope.toJson = angular.toJson;
        $scope.newFigure = newFigure;
        $scope.addFigure = function() {fctrl42.arr.push(newFigure());};
        $scope.deleteFigure = function() {(fctrl42.arr.length>0) && fctrl42.arr.pop()};
        $scope.rotateFigures = function() {
            (fctrl42.arr.length>0) && 
                fctrl42.arr.unshift(fctrl42.arr.pop())
        };
        $scope.defaultFigures = defaultFigures;
    }
    app.controller('FiguresController', ['$scope',scopeInit])
})()
