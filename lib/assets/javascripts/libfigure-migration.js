// a JSON-to-JSON translater used by a migration

function originalToJSLibFigure(figures) {
  return figures.map(originalToJSLibFigure1);
}

function originalToJSLibFigure1(figure) {
  var move = translateMoveName(figure.move);
  var params = parameters(move);
  var get_parameter_values = function (param) {
    if (param.name === 'who') {
      return translateWho(figure.who);
    } else if (param.name === 'beats') {
      return figure.beats;
    } else if (param.name === 'bal') {
      return figure.balance || false;
    } else if (param.name === 'hand') {
      return oldMoveIsClockwise(figure.move);
    } else if (param.name === 'circling' || param.name === 'places') {
      return figure.degrees;
    } else {
      throw_up("param name '"+param.name+"' missing from originalToJSLibFigure");
    }
  };
  return {parameter_values: params.map(get_parameter_values), move: move};
}

var _translate_move_name = {
  allemande_left: 'allemande',
  allemande_right: 'allemande'
}
function translateMoveName(oldMove) {
  return _translate_move_name[oldMove] || oldMove.replace(/_/g, ' ');
}

var _translate_who = {neighbor: 'neighbors',
                      partner: 'partners',
                      everybody: 'everyone'};

function translateWho(oldWho) {
  return _translate_who[oldWho] || oldWho;
}

var _old_move_is_clockwise = {
  box_the_gnat: true,
  swat_the_flea: false,
  circle_left: true,
  circle_right: false,
  allemande_left: false,
  allemande_right: true
}

function oldMoveIsClockwise(oldMove) {
  var cw = _old_move_is_clockwise[oldMove];
  if (cw === true || cw === false) {
    return cw;
  } else {
    throw_up("move '"+oldMove+"' missing from oldMoveIsClockwise table");
  }
}
