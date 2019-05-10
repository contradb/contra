// GENERATED FILE - source is in "/home/dm/contra/app/javascript/libfigure/words.js" - regenerate this with bin/rake libfigure:compile
/***/ function Words(arr) {
/***/   this.arr = arr;
/***/ }
/***/ 
/***/ function words () {
/***/   return new Words(Array.prototype.slice.call(arguments));
/***/ }
/***/ 
/***/ Words.prototype.scrunched = function() {return false;};
/***/ 
/***/ // ____ ScrunchedWords are Words that don't insert spaces
/***/ //      between arguments as agressively as regular words
/***/ 
/***/ function ScrunchedWords(arr) {
/***/   Words.call(this, arr);
/***/ }
/***/ 
/***/ ScrunchedWords.prototype = Object.create(Words.prototype);
/***/ ScrunchedWords.prototype.constructor = ScrunchedWords;
/***/ 
/***/ ScrunchedWords.prototype.scrunched = function() {return true;};
/***/ 
/***/ // ____ ScrunchedWords end
/***/ 
/***/ 
/***/ var wants_no_space_before = [false, null, ',', '.', ';'];
/***/ 
/***/ var FLATTEN_FORMAT_MARKDOWN = 1001;
/***/ var FLATTEN_FORMAT_HTML = 1002;
/***/ var FLATTEN_FORMAT_UNSAFE_TEXT = 1003;
/***/ var FLATTEN_FORMAT_SAFE_TEXT = 1004;
/***/ 
/***/ // returns *sanitized* html
/***/ Words.prototype.toHtml = function() {
/***/   return this.flatten(FLATTEN_FORMAT_HTML);
/***/ };
/***/ 
/***/ // returns *unsanitized* string with Tags (see below) lobotimized into text.
/***/ // May do whitespace dialation ala html, but at least it preserves newlines.
/***/ Words.prototype.toUnsafeText = function() {
/***/   return this.flatten(FLATTEN_FORMAT_UNSAFE_TEXT);
/***/ };
/***/ 
/***/ // returns *sanitized* e.g. <b>pb&j</b> → &lt;b&gt;pb&amp;a&lt;b&gt;
/***/ // but is different from toHtml because any Tags (see below) are
/***/ // flattened with no bracketing tags, they're all body.
/***/ Words.prototype.toSafeText = function() {
/***/   return this.flatten(FLATTEN_FORMAT_SAFE_TEXT);
/***/ };
/***/ 
/***/ // returns *unsanitized* string with Tags (see below) rendered as html (not Markdown)
/***/ // This preserves newlines, unlike toHtml.
/***/ // It's assumed to be headed for a markdown parser that takes care of that.
/***/ Words.prototype.toMarkdown = function() {
/***/   return this.flatten(FLATTEN_FORMAT_MARKDOWN);
/***/ };
/***/ 
/***/ Words.prototype.flatten = function(format) {
/***/   var arr = this.arr;
/***/   var acc = [];
/***/   var space_before = false;
/***/   for (var i=0; i<arr.length; i++) {
/***/     var wants_space_before = (!this.scrunched()) && (-1 === wants_no_space_before.indexOf(peek(arr[i])));
/***/     if (wants_space_before) {
/***/       acc.push(' ');
/***/     }
/***/     acc.push(flattenWordNode(arr[i], format));
/***/   }
/***/   return trimButLeaveNewlines(acc.join(''));
/***/ }
/***/ 
/***/ Words.prototype.peek = function() {
/***/   for (var i = 0; i < this.arr.length; i++) {
/***/     var p = peek(this.arr[i]);
/***/     if (p) {
/***/       return p;
/***/     }
/***/   }
/***/   return null;
/***/ }
/***/ 
/***/ function Tag(tag, attrs, body) {
/***/   this.tag = tag;
/***/   this.attrs = attrs;
/***/   this.body = body;
/***/ }
/***/ 
/***/ function tag(tag, body) {
/***/   return new Tag(tag, {}, body);
/***/ }
/***/ 
/***/ // function tag_attrs(tag, attrs, body) {
/***/ //   return new Tag(tag, attrs, body);
/***/ // }
/***/ 
/***/ Tag.prototype.flatten = function (format) {
/***/   if (format === FLATTEN_FORMAT_UNSAFE_TEXT || format === FLATTEN_FORMAT_SAFE_TEXT) {
/***/     return flattenWordNode(this.body, format);
/***/   } else if (format === FLATTEN_FORMAT_MARKDOWN || format === FLATTEN_FORMAT_HTML) {
/***/     Object.keys(this.attrs).length === 0 || throw_up('attrs not yet implemented, but used');
/***/     return '<' + this.tag + '>' + flattenWordNode(this.body, format) + '</' + this.tag + '>';
/***/   } else {
/***/     throw_up('unexpected word flatten format :'+format.toString());
/***/   }
/***/ }
/***/ 
/***/ Tag.prototype.peek = function () {
/***/   return peek(this.body);
/***/ }
/***/ 
/***/ var sanitizationMap = {
/***/   '<': '&lt;',
/***/   '>': '&gt;',
/***/   '&': '&amp;',
/***/   '&amp;': '&amp;'
/***/ };
/***/ 
/***/ function flattenWordNode(s, format) {
/***/   if (s.flatten) {
/***/     return s.flatten(format);
/***/   } else if ('string' === typeof s) {
/***/     if (format === FLATTEN_FORMAT_HTML || format === FLATTEN_FORMAT_SAFE_TEXT) {
/***/       var replacer = function(match) {
/***/         return sanitizationMap[match] || throw_up('Unexpected match during flatten sanitize');
/***/       };
/***/       return s.replace(/&amp;|&|<|>/g, replacer);
/***/     } else if (format === FLATTEN_FORMAT_MARKDOWN || format === FLATTEN_FORMAT_UNSAFE_TEXT) {
/***/       return s;
/***/     } else {
/***/       throw_up('unexpected flatten format: '+format.toString());
/***/     }
/***/   } else if (comma === s) {
/***/     return ',';
/***/   } else if (false === s) {
/***/     return '';
/***/   } else {
/***/     return ''+s;
/***/   }
/***/ }
/***/ 
/***/ // returns first non-whitespace character
/***/ function peek(thing) {
/***/   var m;
/***/   if (thing.peek) {
/***/     return thing.peek();
/***/   } else if ((typeof thing === 'string') && (m = thing.match(/[\S\n]/))) {
/***/     return m[0];
/***/   } else if (thing == comma) {
/***/     return ',';
/***/   } else if (thing == false) {
/***/     return null;
/***/   } else {
/***/     return null;
/***/   }
/***/ }
/***/ 
/***/ function trimButLeaveNewlines(s) {
/***/   var start;
/***/   var end;
/***/   for (start=0; start<s.length; start++) {
/***/     if (s[start].match(/[\S\n]/)) {
/***/       break;
/***/     }
/***/   }
/***/   for (end=s.length-1; end>=start; end--) {
/***/     if (s[end].match(/[\S\n]/)) {
/***/       break;
/***/     }
/***/   }
/***/   return s.slice(start, end+1);
/***/ }
/***/ 
/***/ ////////////////////////////////////////////////////////////////
/***/ 
/***/ var comma = ['comma'];
/***/ 
/***/ ////////////////////////////////////////////////////////////////
/***/ 
/***/ // clamp words in <s> or <u> - string is already in-dialect at the point when this proceess it
/***/ function lingoLineWords(string, dialect) {
/***/   // lookbehind doesn't work in all versions of js, so we've got to use capture groups for word boundaries, sigh
/***/   var underlines_and_strikes = underlinesAndStrikes(dialect);
/***/   var all_lingo_lines = underlines_and_strikes.underlines.concat(underlines_and_strikes.strikes).sort(longestFirstSortFn);
/***/   var regex = new RegExp('(\\s|'+PUNCTUATION_CHARSET_STRING+'|^)(' + all_lingo_lines.map(regExpEscape).join('|') + ')(\\s|'+PUNCTUATION_CHARSET_STRING+'|$)','ig');
/***/   var buffer = [];
/***/   var last_match_ended_at;
/***/   while (true) {
/***/     last_match_ended_at = regex.lastIndex;
/***/     var match_info = regex.exec(string);
/***/     if (!match_info) break;
/***/     buffer.push(string.slice(last_match_ended_at, match_info.index));
/***/     var is_strike = underlines_and_strikes.strikes.indexOf(match_info[2].toLowerCase()) >= 0;
/***/     buffer.push(match_info[1]); // its whitespace, but it might be a newline
/***/     buffer.push(tag(is_strike ? 's' : 'u', match_info[2]));
/***/     regex.lastIndex = regex.lastIndex - match_info[3].length; // put back trailing whitespace
/***/   }
/***/   buffer.push(string.slice(last_match_ended_at));
/***/   return new ScrunchedWords(buffer);
/***/ }
/***/ 
/***/ var bogusTerms = ['men', 'women', 'man', 'woman', 'gentlemen', 'gentleman',
/***/                   'gents', 'gent', 'ladies', 'lady',
/***/                   'leads', 'lead', 'follows', 'follow',
/***/                   'larks', 'lark', 'ravens', 'raven',
/***/                   'sex',
/***/                   'gypsy', 'yearn', "rory o'moore", 'rollaway', 'roll-away',
/***/                   'nn', 'n', 'p', 'l', 'g', 'm', 'w', 'n.', 'p.', 'l.', 'g.', 'm.', 'w.', 'g1', 'g2', 'l1', 'l2'];
/***/ 
/***/ var terms_for_uands;
/***/ // NB on return value: it is freshly allocated each time
/***/ function underlinesAndStrikes(dialect) {
/***/   if (!terms_for_uands) {terms_for_uands = moves().concat(dancers());}
/***/   var underlines = terms_for_uands.map(function(term) {
/***/     var substitution = dialect.dancers[term] || dialect.moves[term];
/***/     return (substitution ? stripPercentS(substitution) : term).toLowerCase();
/***/   });
/***/   var strikes = terms_for_uands.concat(bogusTerms).filter(function(s) {return -1 === underlines.indexOf(s.toLowerCase());});
/***/   return {underlines: underlines, strikes: strikes};
/***/ }
/***/ 
/***/ function stripPercentS(str) {
/***/   return str.replace(/%S/g, '').trim();
/***/ }
