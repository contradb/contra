import { trimButLeaveNewlines, words, comma, tag, Tag, peek, lingoLineWords,
         FLATTEN_FORMAT_MARKDOWN,
         FLATTEN_FORMAT_HTML,
         FLATTEN_FORMAT_UNSAFE_TEXT,
         FLATTEN_FORMAT_SAFE_TEXT,
       } from 'libfigure/words.js';
import { testDialect } from 'libfigure/util.js';
import { moves } from 'libfigure/libfigure.js';

describe('trimButLeaveNewlines', () => {
  test('', () => {expect(trimButLeaveNewlines('')).toEqual('');});
  test('', () => {expect(trimButLeaveNewlines(' ')).toEqual('');});
  test('', () => {expect(trimButLeaveNewlines('\n')).toEqual('\n');});
  test('', () => {expect(trimButLeaveNewlines('\n ')).toEqual('\n');});
  test('', () => {expect(trimButLeaveNewlines(' \n')).toEqual('\n');});
  test('', () => {expect(trimButLeaveNewlines(' dog ')).toEqual('dog');});
  test('', () => {expect(trimButLeaveNewlines('dog ')).toEqual('dog');});
  test('', () => {expect(trimButLeaveNewlines(' dog')).toEqual('dog');});
  test('', () => {expect(trimButLeaveNewlines('dog')).toEqual('dog');});
});

describe('Words.toHtml()', () => {
  test('', () => expect(words('<p>hi & stuff</p>').toHtml()).toEqual('&lt;p&gt;hi &amp; stuff&lt;/p&gt;'));
  test('', () => expect(new Tag('p', {}, 'hi & stuff').flatten(FLATTEN_FORMAT_HTML)).toEqual('<p>hi &amp; stuff</p>'));
  test('', () => expect(words('hello', tag('p', 'hi & stuff'), 'hello').toHtml()).toEqual('hello <p>hi &amp; stuff</p> hello'));
  test('', () => expect(words('mad robin', false, comma, 'gentlespoons in front').toHtml()).toEqual('mad robin, gentlespoons in front'));
  test('', () => expect(words('\n').toHtml()).toEqual('\n'));
});

describe('Words.toMarkdown()', () => {
  test('', () => expect(words('<p>hi & stuff</p>').toMarkdown()).toEqual('<p>hi & stuff</p>'));
  test('', () => expect(new Tag('p', {}, 'hi & stuff').flatten(FLATTEN_FORMAT_MARKDOWN)).toEqual('<p>hi & stuff</p>'));
  test('', () => expect(words('hello', tag('p', 'hi & stuff'), 'hello').toMarkdown()).toEqual('hello <p>hi & stuff</p> hello'));
  test('', () => expect(words('mad robin', false, comma, 'gentlespoons in front').toMarkdown()).toEqual('mad robin, gentlespoons in front'));
  test('', () => expect(words('\n').toMarkdown()).toEqual('\n'));
});

describe('peek()', () => {
  test('', () => expect(peek('')).toEqual(null));
  test('', () => expect(peek(words(''))).toEqual(null));
  test('', () => expect(peek(words(false))).toEqual(null));
  test('', () => expect(peek(' ')).toEqual(null));
  test('', () => expect(peek(' hi')).toEqual('h'));
  test('', () => expect(peek(words(false, '   ', 'hi'))).toEqual('h'));
  test('', () => expect(peek(words(false, '   ', comma))).toEqual(','));
  test('', () => expect(peek(tag('i', 'hi'))).toEqual('h'));
  test('', () => expect(peek(words(words('  '), words(false), words('hi')))).toEqual('h'));
  test('', () => expect(peek(words('\n'))).toEqual('\n'));
});

describe('linkLineWords()', () => {
  const d = testDialect;
  test('', () => expect(lingoLineWords('foomenfoo', d).toHtml()).toEqual('foomenfoo'));
  test('', () => expect(lingoLineWords('foo men foo', d).toHtml()).toEqual('foo <s>men</s> foo'));
  test('', () => expect(lingoLineWords('http://veino.com/blog?p=2175', d).toHtml()).toEqual('http://veino.com/blog?p=2175'));
  test('', () => expect(lingoLineWords('foo women foo', d).toHtml()).toEqual('foo <s>women</s> foo'));
  test('', () => expect(lingoLineWords('men men', d).toHtml()).toEqual('<s>men</s> <s>men</s>'));
  test('', () => expect(lingoLineWords('men salarymen men men', d).toHtml()).toEqual('<s>men</s> salarymen <s>men</s> <s>men</s>'));
  test('', () => expect(lingoLineWords('gentlespoons larks gents', d).toHtml()).toEqual('<s>gentlespoons</s> <u>larks</u> <s>gents</s>'));
  test('', () => expect(lingoLineWords('g1 G1', d).toHtml()).toEqual('<s>g1</s> <s>G1</s>'));
  test('', () => expect(lingoLineWords('LARKS', d).toHtml()).toEqual('<u>LARKS</u>'));
  test('', () => expect(lingoLineWords("Rory O'More", d).toHtml()).toEqual("<u>Rory O'More</u>"));
  test('', () => expect(lingoLineWords("rory o'more", d).toHtml()).toEqual("<u>rory o'more</u>"));
  test('', () => expect(lingoLineWords('foo"bar<>&', {moves: {swing: 'foo"bar<>&'}, dancers: {}}).toHtml()).toEqual('<u>foo"bar&lt;&gt;&amp;</u>'));
  test('', () => expect(lingoLineWords('fo+ foo', {moves: {swing: 'fo+'}, dancers: {}}).toHtml()).toEqual('<u>fo+</u> foo'));
  test('', () => expect(lingoLineWords('swing\nswing', d).toMarkdown()).toEqual('<u>swing</u>\n<u>swing</u>'));
  test('', () => expect(lingoLineWords('swing\nswing', d).toHtml()).toEqual('<u>swing</u>\n<u>swing</u>')); // \n used to be ' ', but I guess \n is ok too
  test('', () => expect(lingoLineWords(' men-men(men)men.men[men]men men\nmen{men}men;men*men men ', d).toHtml()).toEqual(' <s>men</s>-<s>men</s>(<s>men</s>)<s>men</s>.<s>men</s>[<s>men</s>]<s>men</s> <s>men</s>\n<s>men</s>{<s>men</s>}<s>men</s>;<s>men</s>*<s>men</s> <s>men</s> '.trim())); // don't really care that it's trimmed
  test('', () => expect(lingoLineWords('Larks larks lARkS', d).toHtml()).toEqual('<u>Larks</u> <u>larks</u> <u>lARkS</u>'));
  test('', () => expect(lingoLineWords('men MEN mEn', d).toHtml()).toEqual('<s>men</s> <s>MEN</s> <s>mEn</s>'));
  test('', () => expect(lingoLineWords('right shoulder round', {moves: {gyre: '%S shoulder round'}, dancers: {}}).toHtml()).toEqual('right <u>shoulder round</u>'));
  
});
