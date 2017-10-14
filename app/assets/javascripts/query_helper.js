

function buildFigureSentence(query) {
  return 'dances with ' + buildFigureSentenceHelper(query, 'a');
}

function buildFigureSentenceHelper(query, article) {
  var op = query[0];
  var f = figureSentenceDispatchTable[op];
  return f ? f(query, article) : ('figureSentenceDispatchTable['+op+'] is not a function');
}

var figureSentenceDispatchTable = {
  figure: sentenceForFigure,
  and: sentenceForBinOp,
  or: sentenceForBinOp,
  follows: sentenceForBinOp,
  none: sentenceForNone,
  all: sentenceForAll,
  not: sentenceForNot
};

function sentenceForFigure(query, article) {
  var fig = query[1];
  if (fig === '*') {
    return (article === 'a') ? 'any figure' : (article +' figure');
  } else if (article === 'a') {
    return ('aeiou'.indexOf(fig[0]) >= 0) ? ('an ' + fig) : ('a ' + fig); // 'an allemande'
  } else if (article === 'not') {
    return 'non ' + fig;
  } else {
    return article + ' ' + fig;
  }
}

function sentenceForBinOp(query, article) {
  var op = query[0];
  // oxford comma?
  return query.slice(1).map(function(query) { return sentenceForMaybeComplex(query, article); }).join(' '+op+' ');
}

// returns true if sentenceForMaybeComplex uses parens
function isComplex(query, article) {
  var op = query[0];
  return !(op === 'figure' || ('a' === article && (op === 'not' || op === 'none')));
}

function sentenceForMaybeComplex(query, article) {
  // Introduce parens if we start to get confused.
  // Modify isComplex() if you change this function.
  var op = query[0];
  var boringArticle = 'a' === article || '' === article;
  if (op==='figure') {
    return sentenceForFigure(query, article);
  } else if (boringArticle && (op === 'not' || op === 'none')) {
    return buildFigureSentenceHelper(query, article);
  } else if (boringArticle) {
    return '(' + buildFigureSentenceHelper(query, 'a') + ')';
  } else {
    return article + ' (' + buildFigureSentenceHelper(query, 'a') + ')';
  }
}

function sentenceForNone(query, article) {
  var flippedArticle = (article === 'a') ? 'no' : 'a';
  var subop = query[1][0];
  if (subop === 'and' || subop === 'or') {
    // distribute the none, flip the and/or
    var new_query = query[1].slice(1);
    new_query.unshift ((subop === 'and') ? 'or' : 'and');
    return buildFigureSentenceHelper(new_query, flippedArticle);
  } else if (subop === 'figure') {
    return buildFigureSentenceHelper(query[1], flippedArticle);
  } else {
    return (article === 'a' ? '' : article) + ' no ' + sentenceForMaybeComplex(query[1], '');
  }
}

function sentenceForAll(query, article) {
  // could aggressively reduce 'all not' to 'none', but that's too nice
  return 'all (' + buildFigureSentenceHelper(query[1], article) + ')';
}

function sentenceForNot(query, article) {
  if (isComplex(query[1], article)) {
    return 'not '+ sentenceForMaybeComplex(query[1], 'a');
  } else {
    return article + ' non ' + sentenceForMaybeComplex(query[1], '');
  }
}
