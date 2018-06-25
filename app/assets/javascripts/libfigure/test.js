function testTrimButLeaveNewlines(s) {
  var t = 0;
  ++t && (trimButLeaveNewlines('') === '') || throw_up('test '+ t + ' failed');
  ++t && (trimButLeaveNewlines(' ') === '') || throw_up('test '+ t + ' failed');
  ++t && (trimButLeaveNewlines('\n') === '\n') || throw_up('test '+ t + ' failed');
  ++t && (trimButLeaveNewlines('\n ') === '\n') || throw_up('test '+ t + ' failed');
  ++t && (trimButLeaveNewlines(' \n') === '\n') || throw_up('test '+ t + ' failed');
  ++t && (trimButLeaveNewlines(' dog ') === 'dog') || throw_up('test '+ t + ' failed');
  ++t && (trimButLeaveNewlines('dog ') === 'dog') || throw_up('test '+ t + ' failed');
  ++t && (trimButLeaveNewlines(' dog') === 'dog') || throw_up('test '+ t + ' failed');
  ++t && (trimButLeaveNewlines('dog') === 'dog') || throw_up('test '+ t + ' failed');
  return t;
}

function test_sanitize() {
  (words('<p>hi & stuff</p>').sanitize() == '&lt;p&gt;hi &amp; stuff&lt;/p&gt;') || throw_up('test 1 failed');
  (new Tag('p', {}, 'hi & stuff').sanitize() == '<p>hi &amp; stuff</p>') || throw_up('test 2 failed');
  (words('hello', tag('p', 'hi & stuff'), 'hello').sanitize() == 'hello <p>hi &amp; stuff</p> hello') || throw_up('test 3 failed');
  (words('mad robin', false, comma, 'gentlespoons in front').sanitize() == 'mad robin, gentlespoons in front') || throw_up('test 4 failed');
  (words('\n').sanitize() === '\n' || throw_up('test 5 failed'));
  return 'success';
}

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
  ++t && (peek(words('\n')) === '\n') || throw_up('test '+ t + ' failed');
  return 'success';
}

function testLingoLineWords(string) {
  var d = testDialect;
  var t = 0;
  ++t && (lingoLineWords('foomenfoo', d).sanitize() === 'foomenfoo') || throw_up('test '+ t + ' failed');
  ++t && (lingoLineWords('foo men foo', d).sanitize() === 'foo <s>men</s> foo') || throw_up('test '+ t + ' failed');
  ++t && (lingoLineWords('foo women foo', d).sanitize() === 'foo <s>women</s> foo') || throw_up('test '+ t + ' failed');
  ++t && (lingoLineWords('men men', d).sanitize() === '<s>men</s> <s>men</s>') || throw_up('test '+ t + ' failed');
  ++t && (lingoLineWords('men salarymen men men', d).sanitize() === '<s>men</s> salarymen <s>men</s> <s>men</s>') || throw_up('test '+ t + ' failed');
  ++t && (lingoLineWords('gentlespoons larks gents', d).sanitize() === '<s>gentlespoons</s> <u>larks</u> <s>gents</s>') || throw_up('test '+ t + ' failed');
  ++t && (lingoLineWords('g1 G1', d).sanitize() === '<s>g1</s> <s>G1</s>') || throw_up('test '+ t + ' failed');
  ++t && (lingoLineWords('LARKS', d).sanitize() === '<u>LARKS</u>') || throw_up('test '+ t + ' failed');
  ++t && (lingoLineWords("Rory O'More", d).sanitize() === "<u>Rory O'More</u>") || throw_up('test '+ t + ' failed');
  ++t && (lingoLineWords("rory o'more", d).sanitize() === "<u>rory o'more</u>") || throw_up('test '+ t + ' failed');
  ++t && (lingoLineWords('foo"bar<>&', {moves: {swing: 'foo"bar<>&'}, dancers: {}}).sanitize() === '<u>foo"bar&lt;&gt;&amp;</u>') || throw_up('test '+ t + ' failed');
  ++t && (lingoLineWords('fo+ foo', {moves: {swing: 'fo+'}, dancers: {}}).sanitize() === '<u>fo+</u> foo') || throw_up('test '+ t + ' failed'); // regexpes escaped
  ++t && (lingoLineWords('swing\nswing', d).sanitize() === '<u>swing</u> \n <u>swing</u>') || throw_up('test '+ t + ' failed');
  
  return ''+t+' successful tests';
}
