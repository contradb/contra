// GENERATED FILE - source is in "/home/dm/contra/app/javascript/libfigure/move.js" - regenerate this with bin/rake libfigure:compile
/***/ //       __  __  _____     _______ 
/***/ //      |  \/  |/ _ \ \   / / ____|
/***/ //      | |\/| | | | \ \ / /|  _|  
/***/ //      | |  | | |_| |\ V / | |___ 
/***/ //      |_|  |_|\___/  \_/  |_____|
/***/ //                                 
/***/ //
/***/ // Properties of moves (strings).
/***/ // Few dependencies to the rest of the system.
/***/ 
/***/ var moveCaresAboutRotationsHash =
/***/     {"do si do":  true
/***/     ,"allemande": true
/***/     ,"gyre":      true
/***/     ,"allemande orbit": true
/***/     ,"star promenade": true
/***/     ,"mad robin": true
/***/     };
/***/ // it now seems to me that this should be defined by defineFigure -dm 03-07-2017
/***/ function moveCaresAboutRotations (move) {
/***/     return moveCaresAboutRotationsHash[deAliasMove(move)];
/***/ }
/***/ 
/***/ var moveCaresAboutPlacesHash =
/***/     {circle: true
/***/     , star: true
/***/     , 'facing star': true
/***/     , 'square through': true
/***/     , 'box circulate': true
/***/     };
/***/ // it now seems to me that this should be defined by defineFigure -dm 03-07-2017
/***/ function moveCaresAboutPlaces (move) {
/***/     return moveCaresAboutPlacesHash[deAliasMove(move)];
/***/ }
/***/ 
/***/ var degrees2rotations = { 90: "¼", 
/***/                          180: "½", 
/***/                          270: "¾",
/***/                          360: "once",
/***/                          450: "1¼",
/***/                          540: "1½",
/***/                          630: "1¾",
/***/                          720: "twice",
/***/                          810: "2¼",
/***/                          900: "2½",
/***/                          '*': "*"
/***/                         };
/***/ 
/***/ var degrees2places = { 90: "1 place", 
/***/                       180: "2 places", 
/***/                       270: "3 places",
/***/                       360: "4 places",
/***/                       450: "5 places",
/***/                       540: "6 places",
/***/                       630: "7 places",
/***/                       720: "8 places",
/***/                       810: "9 places",
/***/                       900: "10 places",
/***/                       '*': "* places"
/***/                      };
/***/ 
/***/ function degreesToWords (degrees,optional_move) {
/***/   if (optional_move) {
/***/     if (moveCaresAboutRotations(optional_move) && degrees2rotations[degrees]) {
/***/       return degrees2rotations[degrees];
/***/     } else if (moveCaresAboutPlaces(optional_move) && degrees2places[degrees]) {
/***/       return degrees2places[degrees];
/***/     }
/***/   }
/***/   return degrees.toString() + ' degrees';
/***/ }
/***/ 
/***/ function degreesToRotations(degrees) {
/***/   if (degrees) {
/***/     return degrees2rotations[degrees] || (degrees.toString() + " degrees");
/***/   } else {
/***/     return "?";
/***/   }
/***/ }
/***/ 
/***/ function degreesToPlaces(degrees) {
/***/   if (degrees) {
/***/     return degrees2places[degrees] || (degrees.toString() + " degrees");
/***/   } else {
/***/     return "? places";
/***/   }
/***/ }
/***/ 
/***/ var anglesForMoveArr = [90,180,270,360,450,540,630,720,810,900];
/***/ 
/***/ function anglesForMove (move) {
/***/   if (move === 'square through') {
/***/     return [180, 270, 360];
/***/   } else if (move === 'box circulate') {
/***/     return [90, 180, 270, 360];
/***/   } else {
/***/     return anglesForMoveArr;
/***/   }
/***/ }
