// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.




var moveCaresAboutBalancesArr = ["petronella", "swing", "pull_by_right", "pull_by_left", "box_the_gnat", "swat_the_flea", "california_twirl", "arizona_twirl", "slide_right_rory_o_moore", "slide_left_rory_o_moore", "custom"];
function moveCaresAboutBalance (move) {
    return 0 <= moveCaresAboutBalancesArr.indexOf(move)
}


// NOTE: this constant is duplicated rubyside in dances_helper.rb. Sync them.
var moveCaresAboutRotationsArr = 
    ["do_si_do"               , "see_saw"
    ,"allemande_right"        , "allemande_left"
    ,"gyre_right_shoulder"    , "gyre_left_shoulder"
    ,"star_promenade"
    ,"butterfly_whirl"
    ,"mad_robin"
    ];
function moveCaresAboutRotations (move) {
    return 0 <= moveCaresAboutRotationsArr.indexOf(move)
}

// NOTE: this constant is duplicated rubyside in dances_helper.rb. Sync them.
var moveCaresAboutPlacesArr = 
    ["circle_left"            , "circle_right"
    , "star_left"             , "star_right"
    , "gyre_star_clockwise_ladles_backing"
    , "gyre_star_ccw_ladles_backing"
    , "gyre_star_clockwise_gentlespoons_backing"
    , "gyre_star_ccw_gentlespoons_backing"
    ]
function moveCaresAboutPlaces (move) {
    return 0 <= moveCaresAboutPlacesArr.indexOf(move)
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
function degreesToHumanUnits (degrees,optional_move) {
    if (moveCaresAboutRotations(optional_move) && degrees2rotations[degrees]) 
        return degrees2rotations[degrees];
    else if (moveCaresAboutPlaces(optional_move) && degrees2places[degrees]) 
        return degrees2places[degrees];
    return degrees.toString();
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

function moveMenuOptions (formation,who) {
    var r = []; // the return value
    if (who == "") { return []; } 
    else switch(formation) {
    case "short_lines":
        r = (who == "everybody") ? ["down_the_hall","up_the_hall","dixie_twirl"] : []
        break;

    case "short_wavy_lines":
        switch (who) {
        case "everybody":
            r = ["allemande_and_orbit", 
                 "slide_right_rory_o_moore", "slide_left_rory_o_moore",
                 "half_a_hey", "hey"];
            break;
        case "ladles":
        case "gentlespoons":
        case "partner":
        case "neighbor":
        case "centers":
        case "ones":
        case "twos":
            r = ["allemande_left", "allemande_right", 
                 "arizona_twirl",
                 "box_the_gnat",
                 "california_twirl",
                 "do_si_do",
                 "gyre_left_shoulder", "gyre_right_shoulder",
                 "pull_by_left", "pull_by_right",
                 "roll_away_half_sashay", 
                 "see_saw", 
                 "swat_the_flea", 
                 "swing"];
            break;
        default: r = []; break;
        }
        break;
    case "long_wavy_lines":     // two paralell lines, that happen to be wavy
        
        switch (who) {
        case "everybody": 
            r = ["box_circulate",
                 "hey", "half_a_hey",
                 "slide_right_rory_o_moore", "slide_left_rory_o_moore"];
            break;
        case  "partner":
        case  "neighbor":
            r = ["allemande_left", "allemande_right", 
                 "arizona_twirl", 
                 "box_the_gnat", 
                 "california_twirl",
                 "do_si_do", 
                 "gyre_left_shoulder", "gyre_right_shoulder", 
                 "pull_by_left",
                 "pull_by_right",
                 "see_saw", 
                 "swat_the_flea",
                 "swing"] ;
            break;
        case  "ladles":
        case  "gentlespoons":
            r = ["roll_away_half_sashay"];
            break;
        default: r = []; break;
        }
        break;
    case "long_wavy_line":
        switch (who) {
        case  "ladles":
        case "gentlespoons":
            r = ["allemande_left", "allemande_right", 
                 "arizona_twirl", 
                 "balance", 
                 "box_the_gnat",
                 "california_twirl", 
                 "do_si_do", 
                 "gyre_left_shoulder", 
                 "gyre_right_shoulder", 
                 "pull_by_left", "pull_by_right", 
                 "see_saw",
                 "slide_left_rory_o_moore", "slide_right_rory_o_moore", 
                 "swat_the_flea",
                 "swing"];
            break;
        default: r = []; break;
        }
        break;
    case "square":
    case "custom":
    case "":
    case null:
    case undefined:
        switch (who) {
        case "everybody":
            r = ["balance_the_ring",
                 "circle_left", 
                 "circle_right", 
                 "cross_trails",
                 "gyre_star_ccw_gentlespoons_backing", 
                 "gyre_star_ccw_ladles_backing", 
                 "gyre_star_clockwise_gentlespoons_backing", 
                 "gyre_star_clockwise_ladles_backing", 
                 "long_lines", 
                 "petronella", 
                 "right_left_through", 
                 "slide_left_rory_o_moore", "slide_right_rory_o_moore", 
                 "star_left", "star_right", 
                 "to_ocean_wave"];
            break;
        case "partner":
        case "neighbor": 
            r = ["allemande_left", "allemande_right",
                 "arizona_twirl", 
                 "balance", 
                 "box_the_gnat", 
                 "butterfly_whirl", 
                 "california_twirl", 
                 "do_si_do",
                 "gyre_left_shoulder", "gyre_right_shoulder", 
                 "promenade_across", 
                 "pull_by_left", "pull_by_right", 
                 "see_saw", 
                 "swat_the_flea", 
                 "swing"];
            break;
        case "ladles":
        case "gentlespoons": 
            r = ["allemande_left", "allemande_right", // alphabetic ordering
                 "balance", "chain", 
                 "do_si_do", 
                 "gyre_left_shoulder", "gyre_right_shoulder", 
                 "half_a_hey", "hey", 
                 "mad_robin", 
                 "pull_by_left", "pull_by_right", 
                 "roll_away", "roll_away_half_sashay", 
                 "see_saw", 
                 "star_promenade",
                 "to_long_wavy_line"];
            break;
        case "ones":
        case "twos":
            r = ["contra_corners","figure_8","swing"];
            break;
        default: r = []; break; 
        }
        break;
    }
    r.push("custom");
    return r;
}

// always freshly allocated
function newFigure () {
    return {formation:"square", who:"everybody",beats:8}
}

function defaultFigures (figures) {
    if (figures.length == 0)
        return [newFigure(), newFigure(), newFigure(), newFigure(),
                newFigure(), newFigure(), newFigure(), newFigure()]
    else return figures;
}

(function () {
    var app = angular.module('contra', []);
    var scopeInit = function ($scope) {
        var fctrl42 = this;
        $scope.moveCaresAboutBalance = moveCaresAboutBalance;
        $scope.moveCaresAboutRotations = moveCaresAboutRotations;
        $scope.moveCaresAboutPlaces = moveCaresAboutPlaces;
        $scope.degreesToHumanUnits = degreesToHumanUnits;
        $scope.anglesForMove = anglesForMove;
        $scope.sumBeats = sumBeats;
        $scope.labelForBeats = labelForBeats;
        $scope.styleForBeats = styleForBeats;
        $scope.moveMenuOptions = moveMenuOptions;
        $scope.toJson = angular.toJson;
        $scope.newFigure = newFigure;
        $scope.addFigure = function() {fctrl42.arr.push(newFigure());};
        $scope.deleteFigure = function() {(fctrl42.arr.length>0) && fctrl42.arr.pop()};
        $scope.defaultFigures = defaultFigures;
    }
    app.controller('FiguresController', ['$scope',scopeInit])
})()
