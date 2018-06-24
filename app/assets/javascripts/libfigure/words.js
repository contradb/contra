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
  return acc.join('').trim();// wordsClassic.apply(null, this.arr.map(sanitizeWordNode));
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
    return s.replace(/&amp;|&|<|>/g, function(match) {
      return sanitizationMap[match] || throw_up('Unexpected match during sanitize');
    }).trim();
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
  } else if ((typeof thing === 'string') && (m = thing.match(/\S/))) {
    return m[0];
  } else if (thing == comma) {
    return ',';
  } else if (thing == false) {
    return null;
  } else {
    return null;
  }
}

// function test_sanitize() {
//   (words('<p>hi & stuff</p>').sanitize() == '&lt;p&gt;hi &amp; stuff&lt;/p&gt;') || throw_up('test 1 failed');
//   (new Tag('p', {}, 'hi & stuff').sanitize() == '<p>hi &amp; stuff</p>') || throw_up('test 2 failed');
//   (words('hello', tag('p', 'hi & stuff'), 'hello').sanitize() == 'hello <p>hi &amp; stuff</p> hello') || throw_up('test 3 failed');
//   (words('mad robin', false, comma, 'gentlespoons in front').sanitize() == 'mad robin, gentlespoons in front') || throw_up('test 4 failed');
//   return 'success';
// }

function test_peek() {
  var t = 0;
  ++t && (peek('') === null) || throw_up('test '+ t + ' failed');
  ++t && (peek(words('')) === null) || throw_up('test '+ t + ' failed');
  ++t && (peek(' ') === null) || throw_up('test '+ t + ' failed');
  ++t && (peek(' hi') === 'h') || throw_up('test '+ t + ' failed');
  ++t && (peek(words(false, '   ', 'hi')) === 'h') || throw_up('test '+ t + ' failed');
  ++t && (peek(words(false, '   ', comma)) === ',') || throw_up('test '+ t + ' failed');
  ++t && (peek(tag('i', 'hi')) === 'h') || throw_up('test '+ t + ' failed');
  ++t && (peek(words(words('  '), words(false), words('hi'))) === 'h') || throw_up('test '+ t + ' failed');
  return 'success';
}

////////////////////////////////////////////////////////////////

var comma = ['comma'];

