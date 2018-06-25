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
