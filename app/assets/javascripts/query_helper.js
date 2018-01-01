

function buildFigureSentence(query, prefs) {
  return 'Showing dances with ' + buildFigureSentenceHelper(query, 'a', prefs) + '.';
}

function buildFigureSentenceHelper(query, article, prefs) {
  var op = query[0];
  var f = figureSentenceDispatchTable[op];
  return f ? f(query, article, prefs) : ('figureSentenceDispatchTable['+op+'] is not a function');
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

function sentenceForFigure(query, article, prefs) {
  var move = query[1];
  if (move === '*') {
    return (article === 'a') ? 'any figure' : (article +' figure');
  } else {
    var params = query.slice(2).map(destringifyFigureParam);
    var fig = {move: move, parameter_values: params};
    var fig_text = parameters(move).length === params.length ? figureToString(fig, prefs) : move;
    if (article === 'a') {
      return ('aeiou'.indexOf(fig_text[0]) >= 0) ? ('an ' + fig_text) : ('a ' + fig_text); // 'an allemande'
    } else {
      return article + ' ' + fig_text;
    }
  }
}

function sentenceForBinOp(query, article, prefs) {
  var op = query[0];
  // oxford comma?
  return query.slice(1).map(function(query) { return sentenceForMaybeComplex(query, article, prefs); }).join(' '+op+' ');
}

// returns true if sentenceForMaybeComplex uses parens
function isComplex(query, article) {
  var op = query[0];
  return !(op === 'figure' || ('a' === article && (op === 'anything but' || op === 'no')));
}

function sentenceForMaybeComplex(query, article, prefs) {
  // Introduce parens if we start to get confused.
  // Modify isComplex() if you change this function.
  var op = query[0];
  var boringArticle = 'a' === article || '' === article;
  if (op==='figure') {
    return sentenceForFigure(query, article, prefs);
  } else if (boringArticle && (op === 'anything but' || op === 'no')) {
    return buildFigureSentenceHelper(query, article, prefs);
  } else if (boringArticle) {
    return '(' + buildFigureSentenceHelper(query, 'a', prefs) + ')';
  } else {
    return article + ' (' + buildFigureSentenceHelper(query, 'a', prefs) + ')';
  }
}

function sentenceForNo(query, article, prefs) {
  var flippedArticle = (article === 'a') ? 'no' : 'a';
  var subop = query[1][0];
  if (subop === 'and' || subop === 'or') {
    // distribute the no, flip the and/or
    var new_query = query[1].slice(1);
    new_query.unshift ((subop === 'and') ? 'or' : 'and');
    return buildFigureSentenceHelper(new_query, flippedArticle, prefs);
  } else if (subop === 'figure') {
    return buildFigureSentenceHelper(query[1], flippedArticle, prefs);
  } else {
    return (article === 'a' ? '' : article) + ' no ' + sentenceForMaybeComplex(query[1], '', prefs);
  }
}

function sentenceForAll(query, article, prefs) {
  // could aggressively reduce 'all anything but' to 'no', but that's too nice
  return 'all (' + buildFigureSentenceHelper(query[1], article, prefs) + ')';
}

function sentenceForAnythingBut(query, article, prefs) {
  if (isComplex(query[1], article)) {
    return 'anything but '+ sentenceForMaybeComplex(query[1], 'a', prefs);
  } else {
    return article + ' non ' + sentenceForMaybeComplex(query[1], '', prefs);
  }
}
