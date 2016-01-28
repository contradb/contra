// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.


var moveCaresAboutBalancesArr = ["petronella", "swing", "pull_by_right", "pull_by_left", "box_the_gnat", "swat_the_flea", "california_twirl", "arizona_twirl", "slide_right_rory_o_moore", "slide_left_rory_o_moore", "custom"];
function moveCaresAboutBalance (move) {
    return 0 <= moveCaresAboutBalancesArr.indexOf(move)
}


// NOTE: this constant is duplicated rubyside in dances_helper.rb. Sync them.
var moveCaresAboutRotationsArr = 
    ["do_si_do", "see_saw", "allemande_right", "allemande_left", 
     "gypsy_right_shoulder", "gypsy_left_shoulder"];
function moveCaresAboutRotations (move) {
    return 0 <= moveCaresAboutRotationsArr.indexOf(move)
}

// NOTE: this constant is duplicated rubyside in dances_helper.rb. Sync them.
var moveCaresAboutPlacesArr = ["circle_left", "circle_right", "star_left", "star_right"]
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

function sumBeats(objs,optional_limit) {
    var acc = 0;
    var n = Number.isInteger(optional_limit) ? optional_limit : objs.length;
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
        r = (who == "everybody") ? ["down_the_hall","up_the_hall"] : []
        break;

    case "short_wavy_lines":
        switch (who) {
        case "everybody":
            r = ["slide_right_rory_o_moore", "slide_left_rory_o_moore",
                 "allemande_and_orbit","hey", "half_a_hey"];
            break;
        case "ladles":
        case "gentlespoons":
        case "partner":
        case "neighbor":
        case "centers":
        case "ones":
        case "twos":
            r = [ "swing",
                  "do_si_do", "see_saw", "allemande_right", "allemande_left",
                  "gypsy_right_shoulder", "gypsy_left_shoulder",
                  "pull_by_right", "pull_by_left", 
                  "box_the_gnat", "swat_the_flea", "california_twirl", "arizona_twirl"];
            break;
        default: r = []; break;
        }
        break;
    case "long_wavy_lines":
        
        switch (who) {
        case "everybody": 
            r = ["box_circulate",
                 "slide_right_rory_o_moore", "slide_left_rory_o_moore",
                 "hey", "half_a_hey"];
            break;
        case  "partner":
        case  "neighbor":
            r = [ "swing",
                  "allemande_right", "allemande_left","do_si_do", "see_saw",
                  "gypsy_right_shoulder", "gypsy_left_shoulder",
                  "pull_by_right", "pull_by_left", 
                  "box_the_gnat", "swat_the_flea", "california_twirl", "arizona_twirl"];
            break;
        default: r = []; break;
        }
        break;
    case "long_wavy_line":
        switch (who) {
        case  "ladles":
        case "gentlespoons":
            r = [ "balance","swing",
                  "slide_right_rory_o_moore", "slide_left_rory_o_moore",
                  "allemande_right", "allemande_left","do_si_do", "see_saw",
                  "gypsy_right_shoulder", "gypsy_left_shoulder",
                  "pull_by_right", "pull_by_left", 
                  "box_the_gnat", "swat_the_flea", "california_twirl", "arizona_twirl",
                ];
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
            r = ["circle_left", "circle_right", "star_left", "star_right", "long_lines", 
                 "petronella", "balance_the_ring", "to_ocean_wave", 
                 "slide_right_rory_o_moore", "slide_left_rory_o_moore", // as in Rory'o'Moore
                 "right_left_through"];
            break;
        case "partner":
        case "neighbor": 
            r = [ "swing",
                  "do_si_do", "see_saw", "allemande_right", "allemande_left",
                  "gypsy_right_shoulder", "gypsy_left_shoulder",
                  "pull_by_right", "pull_by_left", 
                  "box_the_gnat", "swat_the_flea", "california_twirl", "arizona_twirl",
                  "promenade_across",
                  "balance"];
            break;
        case "ladles":
        case "gentlespoons": 
            r = [ "chain",
                  "do_si_do", "see_saw", "allemande_right", "allemande_left",
                  "gypsy_right_shoulder", "gypsy_left_shoulder",
                  "chain", "pull_by_right", "pull_by_left",
                  // thought about these two, but...it takes too many parameters
                  // better to leave it as "custom": 
                  // "allemande_left_with_orbit", "allemande_right_with_orbit",
                  "mad_robin", "hey", "half_a_hey",
                  "balance"];
            break;
        case "ones":
        case "twos":
            r = ["swing","figure_8"];
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
