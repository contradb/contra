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
  formation: sentenceForFormation,
  and: sentenceForBinOp,
  or: sentenceForBinOp,
  then: sentenceForBinOp,
  no: sentenceForNo,
  all: sentenceForAll,
  '~': sentenceForFigurewiseNot,
  '&': sentenceForBinOp,
  'progression': sentenceForProgression
};

function destringifyFigureFilterParam(param) {
  // We store values in inputs, and we don't have rails or angular to parse them.
  // Then we mash the values through figure stringifying functions with mixed results.
  // This is a hack to make the worst offenders work.
  // This is a type-unsafe nightmare, and could use improvement.
  // For example: integers for angles? Floats other than "1.0" and "0.5"?
  if ('0.5' === param) {
    return 0.5;
  } else if ('1.0' === param || '1' === param) {
    return 1.0;
  } else if ('false' === param) {
    return false;
  } else if ('true' === param) {
    return true;
  } else {
    return param;
  }
}

function sentenceForFigure(query, article, dialect) {
  var move = query[1];
  if (move === '*') {
    return (article === 'a') ? 'any figure' : (article +' figure');
  } else {
    var params = query.slice(2).map(destringifyFigureFilterParam);
    var fig = {move: move, parameter_values: params};
    var fig_text = parameters(move).length === params.length ? figureToHtml(fig, dialect) : move;
    if (article === 'a') {
      return ('aeiou'.indexOf(fig_text[0]) >= 0) ? ('an ' + fig_text) : ('a ' + fig_text); // 'an allemande'
    } else {
      return article + ' ' + fig_text;
    }
  }
}

function sentenceForFormation(query, article, _dialect) {
  query.length === 2 || throw_up('expected formation query length to be exactly 2');
  var formation = query[1];
  if (formation === '*') {
    return (article === 'a') ? 'any formation' : (article +' formation');
  } else {
    var phrase_without_article = formation + ' formation';
    if (article === 'a') {
      return ('aeiou'.indexOf(formation[0]) >= 0) ? ('an ' + phrase_without_article) : ('a ' + phrase_without_article);
    } else {
      return article + ' ' + phrase_without_article;
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
  return !(op === 'figure' || op === 'formation' || op === 'progression' || ('a' === article && (op === '~' || op === 'no')));
}

function sentenceForMaybeComplex(query, article, dialect) {
  // Introduce parens if we start to get confused.
  // Modify isComplex() if you change this function.
  var op = query[0];
  var boringArticle = 'a' === article || '' === article;
  if (op==='figure') {
    return sentenceForFigure(query, article, dialect);
  } else if (op==='formation') {
    return sentenceForFormation(query, article, dialect);
  } else if (op==='progression') {
    return sentenceForProgression(query, article, dialect);
  } else if (boringArticle && (op === '~' || op === 'no')) {
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
  // could aggressively reduce 'all ~' to 'no', but that's too nice
  return 'all (' + buildFigureSentenceHelper(query[1], article, dialect) + ')';
}

function sentenceForFigurewiseNot(query, article, dialect) {
  if (isComplex(query[1], article)) {
    return '~ '+ sentenceForMaybeComplex(query[1], 'a', dialect);
  } else {
    return article + ' non ' + sentenceForMaybeComplex(query[1], '', dialect);
  }
}

function sentenceForProgression(query, article, dialect) {
  return article + ' progression';
}
