

function buildFigureSentence(query, dialect) {
  return 'Showing dances with ' + buildFigureSentenceHelper(query, 'a', dialect) + '.';
}

function buildFigureSentenceHelper(query, article, dialect) {
  var op = query[0];
  var f = figureSentenceDispatchTable[op];
  return f ? f(query, article, dialect) : ('figureSentenceDispatchTable['+op+'] is not a function');
}

var figureSentenceDispatchTable = {
  figure: sentenceForFigure,
  and: sentenceForBinOp,
  or: sentenceForBinOp,
  then: sentenceForBinOp,
  no: sentenceForNo,
  all: sentenceForAll,
  'anything but': sentenceForAnythingBut
};

function destringifyFigureParam(param) {
  // good enough for now, lol. Maybe want to take arbitrary numbers or bools or something.
  if ('0.5' === param) {
    return 0.5;
  } else if ('1.0' === param || '1' === param) {
    return 1.0;
  } else {
    return param;
  }
}

function sentenceForFigure(query, article, dialect) {
  var move = query[1];
  if (move === '*') {
    return (article === 'a') ? 'any figure' : (article +' figure');
  } else {
    var params = query.slice(2).map(destringifyFigureParam);
    var fig = {move: move, parameter_values: params};
    var fig_text = parameters(move).length === params.length ? figureToString(fig, dialect) : move;
    if (article === 'a') {
      return ('aeiou'.indexOf(fig_text[0]) >= 0) ? ('an ' + fig_text) : ('a ' + fig_text); // 'an allemande'
    } else {
      return article + ' ' + fig_text;
    }
  }
}

function sentenceForBinOp(query, article, dialect) {
  var op = query[0];
  // oxford comma?
  return query.slice(1).map(function(query) { return sentenceForMaybeComplex(query, article, dialect); }).join(' '+op+' ');
}

// returns true if sentenceForMaybeComplex uses parens
function isComplex(query, article) {
  var op = query[0];
  return !(op === 'figure' || ('a' === article && (op === 'anything but' || op === 'no')));
}

function sentenceForMaybeComplex(query, article, dialect) {
  // Introduce parens if we start to get confused.
  // Modify isComplex() if you change this function.
  var op = query[0];
  var boringArticle = 'a' === article || '' === article;
  if (op==='figure') {
    return sentenceForFigure(query, article, dialect);
  } else if (boringArticle && (op === 'anything but' || op === 'no')) {
    return buildFigureSentenceHelper(query, article, dialect);
  } else if (boringArticle) {
    return '(' + buildFigureSentenceHelper(query, 'a', dialect) + ')';
  } else {
    return article + ' (' + buildFigureSentenceHelper(query, 'a', dialect) + ')';
  }
}

function sentenceForNo(query, article, dialect) {
  var flippedArticle = (article === 'a') ? 'no' : 'a';
  var subop = query[1][0];
  if (subop === 'and' || subop === 'or') {
    // distribute the no, flip the and/or
    var new_query = query[1].slice(1);
    new_query.unshift ((subop === 'and') ? 'or' : 'and');
    return buildFigureSentenceHelper(new_query, flippedArticle, dialect);
  } else if (subop === 'figure') {
    return buildFigureSentenceHelper(query[1], flippedArticle, dialect);
  } else {
    return (article === 'a' ? '' : article) + ' no ' + sentenceForMaybeComplex(query[1], '', dialect);
  }
}

function sentenceForAll(query, article, dialect) {
  // could aggressively reduce 'all anything but' to 'no', but that's too nice
  return 'all (' + buildFigureSentenceHelper(query[1], article, dialect) + ')';
}

function sentenceForAnythingBut(query, article, dialect) {
  if (isComplex(query[1], article)) {
    return 'anything but '+ sentenceForMaybeComplex(query[1], 'a', dialect);
  } else {
    return article + ' non ' + sentenceForMaybeComplex(query[1], '', dialect);
  }
}
