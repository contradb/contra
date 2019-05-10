// Each of these tests is called from rspec
// If you add a function here, you have to add a rspec-side test to call it.

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

function test_words_toHtml() {
  (words('<p>hi & stuff</p>').toHtml() == '&lt;p&gt;hi &amp; stuff&lt;/p&gt;') || throw_up('test 1 failed');
  (new Tag('p', {}, 'hi & stuff').flatten(FLATTEN_FORMAT_HTML) == '<p>hi &amp; stuff</p>') || throw_up('test 2 failed'); // tag nodes don't have the helper
  (words('hello', tag('p', 'hi & stuff'), 'hello').toHtml() == 'hello <p>hi &amp; stuff</p> hello') || throw_up('test 3 failed');
  (words('mad robin', false, comma, 'gentlespoons in front').toHtml() == 'mad robin, gentlespoons in front') || throw_up('test 4 failed');
  (words('\n').toHtml() === '\n' || throw_up('test 5 failed')); // changed!
  return 'success';
}

function test_words_toMarkdown() {
  (words('<p>hi & stuff</p>').toMarkdown() == '<p>hi & stuff</p>') || throw_up('test 1 failed');
  (new Tag('p', {}, 'hi & stuff').flatten(FLATTEN_FORMAT_MARKDOWN) == '<p>hi & stuff</p>') || throw_up('test 2 failed');
  (words('hello', tag('p', 'hi & stuff'), 'hello').toMarkdown() == 'hello <p>hi & stuff</p> hello') || throw_up('test 3 failed');
  (words('mad robin', false, comma, 'gentlespoons in front').toMarkdown() == 'mad robin, gentlespoons in front') || throw_up('test 4 failed');
  (words('\n').toMarkdown() === '\n' || throw_up('test 5 failed'));
  return 'success';
}

function test_peek() {
  var t = 0;
  ++t && (peek('') === null) || throw_up('test '+ t + ' failed');
  ++t && (peek(words('')) === null) || throw_up('test '+ t + ' failed');
  ++t && (peek(words(false)) === null) || throw_up('test '+ t + ' failed');
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
  ++t && (lingoLineWords('foomenfoo', d).toHtml() === 'foomenfoo') || throw_up('test '+ t + ' failed');
  ++t && (lingoLineWords('foo men foo', d).toHtml() === 'foo <s>men</s> foo') || throw_up('test '+ t + ' failed');
  ++t && (lingoLineWords('foo women foo', d).toHtml() === 'foo <s>women</s> foo') || throw_up('test '+ t + ' failed');
  ++t && (lingoLineWords('men men', d).toHtml() === '<s>men</s> <s>men</s>') || throw_up('test '+ t + ' failed');
  ++t && (lingoLineWords('men salarymen men men', d).toHtml() === '<s>men</s> salarymen <s>men</s> <s>men</s>') || throw_up('test '+ t + ' failed');
  ++t && (lingoLineWords('gentlespoons larks gents', d).toHtml() === '<s>gentlespoons</s> <u>larks</u> <s>gents</s>') || throw_up('test '+ t + ' failed');
  ++t && (lingoLineWords('g1 G1', d).toHtml() === '<s>g1</s> <s>G1</s>') || throw_up('test '+ t + ' failed');
  ++t && (lingoLineWords('LARKS', d).toHtml() === '<u>LARKS</u>') || throw_up('test '+ t + ' failed');
  ++t && (lingoLineWords("Rory O'More", d).toHtml() === "<u>Rory O'More</u>") || throw_up('test '+ t + ' failed');
  ++t && (lingoLineWords("rory o'more", d).toHtml() === "<u>rory o'more</u>") || throw_up('test '+ t + ' failed');
  ++t && (lingoLineWords('foo"bar<>&', {moves: {swing: 'foo"bar<>&'}, dancers: {}}).toHtml() === '<u>foo"bar&lt;&gt;&amp;</u>') || throw_up('test '+ t + ' failed');
  ++t && (lingoLineWords('fo+ foo', {moves: {swing: 'fo+'}, dancers: {}}).toHtml() === '<u>fo+</u> foo') || throw_up('test '+ t + ' failed'); // regexpes escaped
  ++t && (lingoLineWords('swing\nswing', d).toMarkdown() === '<u>swing</u>\n<u>swing</u>') || throw_up('test '+ t + ' failed');
  ++t && (lingoLineWords('swing\nswing', d).toHtml() === '<u>swing</u>\n<u>swing</u>') || throw_up('test '+ t + ' failed'); // \n used to be ' ', but I guess \n is ok too
  ++t && (lingoLineWords(' men-men(men)men.men[men]men men\nmen{men}men;men*men men ', d).toHtml() === ' <s>men</s>-<s>men</s>(<s>men</s>)<s>men</s>.<s>men</s>[<s>men</s>]<s>men</s> <s>men</s>\n<s>men</s>{<s>men</s>}<s>men</s>;<s>men</s>*<s>men</s> <s>men</s> '.trim()) || throw_up('test '+ t + ' failed'); // don't really care that it's trimmed
  ++t && (lingoLineWords('Larks larks lARkS', d).toHtml() === '<u>Larks</u> <u>larks</u> <u>lARkS</u>') || throw_up('test '+ t + ' failed');
  ++t && (lingoLineWords('men MEN mEn', d).toHtml() === '<s>men</s> <s>MEN</s> <s>mEn</s>') || throw_up('test '+ t + ' failed');
  ++t && (lingoLineWords('right shoulder round', {moves: {gyre: '%S shoulder round'}, dancers: {}}).toHtml() === 'right <u>shoulder round</u>') || throw_up('test '+ t + ' failed'); // wip
  return ''+t+' successful tests';
}
