

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
  } else {
    return article + ' ' + fig;
  }
}

function sentenceForBinOp(query, article) {
  var op = query[0];
  // oxford comma?
  return query.slice(1).map(function(query) { return sentenceForMaybeComplex(query, article); }).join(' '+op+' ');
}

function sentenceForMaybeComplex(query, article) {
  // introduce parens if we start to get confused
  var op = query[0];
  if (op==='figure') {
    return sentenceForFigure(query, article);
  } else {
    return article + ' (' + buildFigureSentenceHelper(query, 'a') + ')';
  }
}

function sentenceForNone(query, article) {
  var flippedArticle = (article === 'a') ? 'no' : 'a';
  var subop = query[1][0];
  if (subop === 'and' || subop === 'or') {
    // distribute the not, flip the and/or
    var new_query = query[1].slice(1);
    new_query.unshift ((subop === 'and') ? 'or' : 'and');
    return buildFigureSentenceHelper(new_query, flippedArticle);
  } else if (subop === 'figure') {
    return buildFigureSentenceHelper(query[1], flippedArticle);
  } else if (subop === 'none') {
    return buildFigureSentenceHelper(query[1][1], article);
  } else {
    return 'no (' + buildFigureSentenceHelper(query[1], article) + ')';
  }
}

function sentenceForAll(query, article) {
  // could aggressively reduce 'all not' to 'none', but that's too nice
  return 'all (' + buildFigureSentenceHelper(query[1], article) + ')';
}

function sentenceForNot(query, article) {
  var subop = query[1][0];
  return article + ' ' + sentenceForMaybeComplex(query[1], 'not');
}

