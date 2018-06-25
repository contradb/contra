function Words(arr) {
  this.arr = arr;
}

function words () {
  return new Words(Array.prototype.slice.call(arguments));
}

var wants_no_space_before = [false, null, ',', '.', ';'];

Words.prototype.sanitize = function() {
  var arr = this.arr;
  var acc = [];
  var space_before = false;
  for (var i=0; i<arr.length; i++) {
    var wants_space_before = -1 === wants_no_space_before.indexOf(peek(arr[i]));
    if (wants_space_before) {
      acc.push(' ');
    }
    acc.push(sanitizeWordNode(arr[i]));
  }
  return trimButLeaveNewlines(acc.join(''));
}

Words.prototype.peek = function() {
  for (var i = 0; i < this.arr.length; i++) {
    var p = peek(this.arr[i]);
    if (p) {
      return p;
    }
  }
  return null;
}

function Tag(tag, attrs, body) {
  this.tag = tag;
  this.attrs = attrs;
  this.body = body;
}

function tag(tag, body) {
  return new Tag(tag, {}, body);
}

// function tag_attrs(tag, attrs, body) {
//   return new Tag(tag, attrs, body);
// }

Tag.prototype.sanitize = function () {
  // TODO: simply sanitize and print attrs
  return '<' + this.tag + '>' + sanitizeWordNode(this.body) + '</' + this.tag + '>';
}

Tag.prototype.peek = function () {
  return peek(this.body);
}

var sanitizationMap = {
  '<': '&lt;',
  '>': '&gt;',
  '&': '&amp;',
  '&amp;': '&amp;'
};

function sanitizeWordNode(s) {
  if (s.sanitize) {
    return s.sanitize();
  } else if ('string' === typeof s) {
    return trimButLeaveNewlines(s.replace(/&amp;|&|<|>/g, function(match) {
      return sanitizationMap[match] || throw_up('Unexpected match during sanitize');
    }));
  } else if (comma === s) {
    return ',';
  } else if (false === s) {
    return '';
  } else {
    return ''+s;
  }
}

// returns first non-whitespace character
function peek(thing) {
  var m;
  if (thing.peek) {
    return thing.peek();
  } else if ((typeof thing === 'string') && (m = thing.match(/[\S\n]/))) {
    return m[0];
  } else if (thing == comma) {
    return ',';
  } else if (thing == false) {
    return null;
  } else {
    return null;
  }
}

function trimButLeaveNewlines(s) {
  var start;
  var end;
  for (start=0; start<s.length; start++) {
    if (s[start].match(/[\S\n]/)) {
      break;
    }
  }
  for (end=s.length-1; end>=start; end--) {
    if (s[end].match(/[\S\n]/)) {
      break;
    }
  }
  return s.slice(start, end+1);
}

////////////////////////////////////////////////////////////////

var comma = ['comma'];

////////////////////////////////////////////////////////////////

function lingoLineWords(string, dialect) {
  // lookbehind doesn't work in all versions of js, so we've got to use capture groups for word boundaries, sigh
  var underlines_and_strikes = underlinesAndStrikes(dialect);
  var all_lingo_lines = underlines_and_strikes.underlines.concat(underlines_and_strikes.strikes).sort(longestFirstSortFn);
  var regex = new RegExp('(\\s|^)(' + all_lingo_lines.map(regExpEscape).join('|') + ')(\\s|$)','ig');
  var buffer = [];
  var last_match_ended_at;
  while (true) {
    last_match_ended_at = regex.lastIndex;
    var match_info = regex.exec(string);
    if (!match_info) break;
    buffer.push(string.slice(last_match_ended_at, match_info.index));
    var is_strike = underlines_and_strikes.strikes.indexOf(match_info[2].toLowerCase()) >= 0;
    buffer.push(match_info[1]); // its whitespace, but it might be a newline
    buffer.push(tag(is_strike ? 's' : 'u', match_info[2]));
    regex.lastIndex = regex.lastIndex - match_info[3].length; // put back trailing whitespace
  }
  buffer.push(string.slice(last_match_ended_at));
  return new Words(buffer);
}

var bogusTerms = ['men', 'women', 'man', 'woman', 'gentlemen', 'gentleman',
                  'gents', 'gent', 'ladies', 'lady',
                  'leads', 'lead', 'follows', 'follow',
                  'larks', 'lark', 'ravens', 'raven',
                  'gypsy', 'yearn', "rory o'moore", 'rollaway', 'roll-away',
                  'nn', 'n', 'p', 'l', 'g', 'm', 'w', 'n.', 'p.', 'l.', 'g.', 'm.', 'w.', 'g1', 'g2', 'l1', 'l2'];

var terms_for_uands;
// NB on return value: it is freshly allocated each time
function underlinesAndStrikes(dialect) {
  if (!terms_for_uands) {terms_for_uands = moves().concat(dancers());}
  var underlines = terms_for_uands.map(function(term) {return (dialect.dancers[term] || dialect.moves[term] || term).toLowerCase();});
  var strikes = terms_for_uands.concat(bogusTerms).filter(function(s) {return -1 === underlines.indexOf(s.toLowerCase());});
  return {underlines: underlines, strikes: strikes};
}
