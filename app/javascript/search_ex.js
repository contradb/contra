import LibFigure from 'libfigure/libfigure.js';

// search node class heirarchy goes here
class  SearchEx {
  constructor({subexpressions = []} = {}) {
    this.subexpressions = subexpressions;
  }
  // subtypes to implement:
  // toLisp()
  // static fromLispHelper(...)
  // static castFrom()
  // static minSubexpressions()
  // static maxSubexpressions()
  // static minUsefulSubexpressions()
  op() {
    // Why use `this.constructor.name2` instead of just using `this.constructor.name`?
    // Because the minimizer used in production strips `this.constructor.name`, and it's faster
    // to just set name2 than to figure out how to turn off webpack or babel or whatever it is.
    return constructorNameToOp[this.constructor.name2];
  }
  static fromLisp(lisp) {
    const constructor = opToConstructor[lisp[0]];
    if (!constructor) {
      throw new Error("lisp doesn't appear to start with an op: "+JSON.stringify(lisp));
    } else if (!constructor.fromLispHelper) {
      throw new Error("must go implement fromLispHelper for some superclass of '" + lisp[0] + "'");
    } else {
      return constructor.fromLispHelper(constructor, lisp);
    }
  }
  castTo(op) {
    return opToConstructor[op].castFrom(this);
  }
  static default() {
    return SearchEx.fromLisp(['figure', '*']);
  }
  minSubexpressions() {return this.constructor.minSubexpressions();}
  maxSubexpressions() {return this.constructor.maxSubexpressions();}
  minUsefulSubexpressions() {return this.constructor.minUsefulSubexpressions();}

  static allProps() {
    // all properties held by any subclass.
    return allProps;
  }

  static mutationNameForProp(propertyName) {
    if (propertyName.length >= 1) {
      return 'set' + propertyName.charAt(0).toUpperCase() + propertyName.slice(1);
    } else {
      throw new Error("propertyName is too short");
    }
  }
};

function registerSearchEx(className, ...props) {
  const op = className.replace(/SearchEx$/, '').replace(/FigurewiseAnd/g, '&').toLowerCase();
  constructorNameToOp[className] = op;
  const constructor = eval(className);
  opToConstructor[op] = constructor;
  constructor.name2 = className;
  if (!opToConstructor[op]) {
    throw new Error('class name ' + className + ' not found');
  }
  for (let prop of props) {
    if (!allProps.includes(prop)) {
      allProps.push(prop);
    }
  }
}

const opToConstructor = {};
const constructorNameToOp = {};
const allProps = [];

registerSearchEx('SearchEx', 'subexpressions');

function errorMissingParameter(name) {
  throw new Error('missing parameter "'+name+'"');
}

let nullaryMixin = Base => class extends Base {
  static maxSubexpressions() { return 0; }
  static minSubexpressions() { return 0; }
  static minUsefulSubexpressions() { return 0; };
  static castFrom(searchEx) {
    return new this();
  }
};

let unaryMixin = Base => class extends Base {
  static maxSubexpressions() { return 1; }
  static minSubexpressions() { return 1; }
  static minUsefulSubexpressions() { return 1; };
  static castFrom(searchEx) {
    return new this(this.castConstructorDefaults(searchEx));
  }
  static castConstructorDefaults(searchEx) {
    return {subexpressions: 1===searchEx.subexpressions.length ? searchEx.subexpressions : [searchEx]};
  }
};

let binaryishMixin = Base => class extends Base {
  static maxSubexpressions() { return Infinity; }
  static minSubexpressions() { return 0; }
  static minUsefulSubexpressions() { return 2; };
  static castFrom(searchEx) {
    if (0 === searchEx.minSubexpressions() && searchEx.maxSubexpressions() > 0) {
      return new this({subexpressions: searchEx.subexpressions});
    } else {
      const ses = [searchEx];
      while (ses.length < this.minUsefulSubexpressions()) {
        ses.push(SearchEx.default());
      }
      return new this({subexpressions: ses});
    }
  }
};

class FigureSearchEx extends nullaryMixin(SearchEx) {
  constructor(args) {
    super(args);
    const {move, parameters = []} = args;
    this._move = move || errorMissingParameter('move');
    this.parameters = parameters;
    this._ellipsis = parameters && parameters.length > 0;
  };
  toLisp() {
    if (this.ellipsis) {
      return [this.op(), this.move, ...this.parameters];
    } else {
      return [this.op(), this.move];
    }
  }
  static fromLispHelper(constructor, lisp) {
    return new constructor({move: lisp[1], parameters: lisp.slice(2)});
  }
  static castFrom(searchEx) {
    return new this({move: '*'});
  }
  get move() {
    return this._move;
  }
  set move(moveString) {
    this._move = moveString;
    this.parameters.length = 0;
    this.padMissingParametersWithAsterisks();
  }
  get ellipsis() {
    return this._ellipsis;
  }
  set ellipsis(expanded) {
    this._ellipsis = expanded;
    this.padMissingParametersWithAsterisks();
  }
  padMissingParametersWithAsterisks() {
    if (this.ellipsis) {
      const formals_length = LibFigure.formalParameters(this.move).length;
      while (this.parameters.length < formals_length)
        this.parameters.push('*');
    }
  }
};
registerSearchEx('FigureSearchEx', 'move', 'parameters', 'ellipsis');

class FormationSearchEx extends nullaryMixin(SearchEx) {
  constructor(args) {
    super(args);
    const {formation} = args;
    this.formation = formation || errorMissingParameter('formation');
  };
  toLisp() {
    return [this.op(), this.formation];
  }
  static fromLispHelper(constructor, lisp) {
    return new constructor({formation: lisp[1]});
  }
  static castFrom(searchEx) {
    return new this({formation: 'improper'});
  }
};
registerSearchEx('FormationSearchEx', 'formation');

class ProgressionSearchEx extends nullaryMixin(SearchEx) {
  toLisp() {
    return [this.op()];
  }
  static fromLispHelper(constructor, lisp) {
    return new constructor();
  }
}
registerSearchEx('ProgressionSearchEx');

class SimpleUnarySearchEx extends unaryMixin(SearchEx) {
  toLisp() {
    return [this.op(), this.subexpressions[0].toLisp()];
  }
  static fromLispHelper(constructor, lisp) {
    return new constructor({subexpressions: [SearchEx.fromLisp(lisp[1])]});
  }
}

// expressions that take just other SearchEx's and no other things.
class SimpleBinaryishSearchEx extends binaryishMixin(SearchEx) {
  toLisp() {
    return [this.op(), ...this.subexpressions.map(searchEx => searchEx.toLisp())];
  }
  static fromLispHelper(constructor, lisp) {
    return new constructor({subexpressions: lisp.slice(1).map(SearchEx.fromLisp)});
  }
}

class NoSearchEx extends SimpleUnarySearchEx {}; registerSearchEx('NoSearchEx');
class NotSearchEx extends SimpleUnarySearchEx {}; registerSearchEx('NotSearchEx');
class AllSearchEx extends SimpleUnarySearchEx {}; registerSearchEx('AllSearchEx');

class AndSearchEx extends SimpleBinaryishSearchEx {}; registerSearchEx('AndSearchEx');
class OrSearchEx extends SimpleBinaryishSearchEx {}; registerSearchEx('OrSearchEx');
class FigurewiseAndSearchEx extends SimpleBinaryishSearchEx {}; registerSearchEx('FigurewiseAndSearchEx');
class ThenSearchEx extends SimpleBinaryishSearchEx {}; registerSearchEx('ThenSearchEx');

class CountSearchEx extends unaryMixin(SearchEx) {
  constructor(args) {
    super(args);
    const {comparison, number} = args;
    this.comparison = comparison || errorMissingParameter('comparison');
    number !== undefined || errorMissingParameter('number');
    this.number = number;
  }
  toLisp() {
    return [this.op(), this.subexpressions[0].toLisp(), this.comparison, this.number];
  }
  static fromLispHelper(constructor, lisp) {
    const [_op, subexpression, comparison, number] = lisp;
    return new constructor({subexpressions: [SearchEx.fromLisp(subexpression)], comparison: comparison, number: number});
  }
  static castConstructorDefaults(searchEx) {
    return {comparison: '>', number: 0, ...super.castConstructorDefaults(searchEx)};
  }
}
registerSearchEx('CountSearchEx', 'comparison', 'number');

function lispEquals(lisp1, lisp2) {
  return JSON.stringify(lisp1) === JSON.stringify(lisp2);
}

function test1() {
  let errors = [];

  [['figure', 'do si do'],
   ['figure', 'swing', 'partners', '*', 8],
   ['formation', 'improper'],
   ['progression'],
   ['or', ['figure', 'do si do'], ['figure', 'swing']],
   ['and', ['figure', 'do si do'], ['figure', 'swing']],
   ['&', ['progression'], ['figure', 'star']],
   ['then', ['figure', 'do si do'], ['figure', 'swing']],
   ['no', ['progression']],
   ['not', ['figure', 'do si do']],
   ['all', ['figure', 'do si do']],
   ['count', ['progression'], '>', 0]
  ].forEach(function(lisp, i) {
    if (!lispEquals(lisp, SearchEx.fromLisp(lisp).toLisp())) {
      errors.push(i);
    }
  });

  if (errors.length > 0) {
    throw new Error('test1 tests ' + JSON.stringify(errors) + ' failed');
  } else {
    return 'tests pass';
  }
}

function test2() {
  let errors = [];

  [{op: 'then', from: ['progression'], expect: ['then', ['progression'], ['figure', '*']]},
   {op: 'then', from: ['not', ['progression']], expect: ['then', ['not', ['progression']], ['figure', '*']]},
   {op: 'then', from: ['and'], expect: ['then']},
   {op: 'then', from: ['and', ['progression']], expect: ['then', ['progression']]},
   {op: 'then', from: ['and', ['progression'], ['figure', 'chain']], expect: ['then', ['progression'], ['figure', 'chain']]},
   {op: 'and', from: ['figure', 'swing'], expect: ['and', ['figure', 'swing'], ['figure', '*']]},
   {op: 'figure', from: ['and'], expect: ['figure', '*']},
   {op: 'formation', from: ['and'], expect: ['formation', 'improper']},
   {op: 'progression', from: ['and'], expect: ['progression']},
   {op: 'no', from: ['and'], expect: ['no', ['and']]},
   {op: 'no', from: ['not', ['figure', '*']], expect: ['no', ['figure', '*']]},
   {op: 'no', from: ['or', ['figure', 'swing'], ['figure', 'chain']], expect: ['no', ['or', ['figure', 'swing'], ['figure', 'chain']]]},
   {op: 'not', from: ['and'], expect: ['not', ['and']]},
   {op: 'not', from: ['no', ['figure', '*']], expect: ['not', ['figure', '*']]},
   {op: 'not', from: ['or', ['figure', 'swing'], ['figure', 'chain']], expect: ['not', ['or', ['figure', 'swing'], ['figure', 'chain']]]},
   {op: 'all', from: ['and'], expect: ['all', ['and']]},
   {op: 'all', from: ['no', ['figure', '*']], expect: ['all', ['figure', '*']]},
   {op: 'all', from: ['or', ['figure', 'swing'], ['figure', 'chain']], expect: ['all', ['or', ['figure', 'swing'], ['figure', 'chain']]]},
   {op: 'count', from: ['and'], expect: ['count', ['and'], '>', 0]},
   {op: 'count', from: ['no', ['figure', '*']], expect: ['count', ['figure', '*'], '>', 0]},
   {op: 'count', from: ['or', ['figure', 'swing'], ['figure', 'chain']], expect: ['count', ['or', ['figure', 'swing'], ['figure', 'chain']], '>', 0]},
  ].forEach(function({from, op, expect}, i) {
    const got = SearchEx.fromLisp(from).castTo(op).toLisp();
    if (!lispEquals(expect, got)) {
      console.log('got ', got, 'expected ', expect);
      errors.push(i);
    }
  });

  if (errors.length > 0) {
    throw new Error('test2 tests ' + JSON.stringify(errors) + ' failed');
  } else {
    return 'tests pass';
  }
}

function testEllipsis1() {
  const searchEx = new FigureSearchEx({move: 'swing', parameters: ['*', '*', 8]});
  const bigLisp = ['figure', 'swing', '*', '*', 8];
  const shortLisp = ['figure', 'swing'];
  if (!lispEquals(searchEx.toLisp(), bigLisp)) throw new Error('testEllipsis failure');
  if (!searchEx.ellipsis) throw new Error('testEllipsis failure');
  searchEx.ellipsis = false;
  if (searchEx.ellipsis) throw new Error('testEllipsis failure');
  if (!lispEquals(searchEx.toLisp(), shortLisp)) throw new Error('testEllipsis failure');
  searchEx.ellipsis = true;
  if (!searchEx.ellipsis) throw new Error('testEllipsis failure');
  if (!lispEquals(searchEx.toLisp(), bigLisp)) throw new Error('testEllipsis failure');
}

function testEllipsis2() {
  const searchEx = new FigureSearchEx({move: 'swing'});
  const bigLisp = ['figure', 'swing', '*', '*', '*'];
  const shortLisp = ['figure', 'swing'];
  if (searchEx.ellipsis) throw new Error('testEllipsis failure');
  if (!lispEquals(searchEx.toLisp(), shortLisp)) throw new Error('testEllipsis failure');
  searchEx.ellipsis = true;
  if (!searchEx.ellipsis) throw new Error('testEllipsis failure');
  if (!lispEquals(searchEx.toLisp(), bigLisp)) throw new Error('testEllipsis failure');
  searchEx.ellipsis = false;
  if (searchEx.ellipsis) throw new Error('testEllipsis failure');
  if (!lispEquals(searchEx.toLisp(), shortLisp)) throw new Error('testEllipsis failure');
}

test1();
test2();
testEllipsis1();
testEllipsis2();

export { SearchEx };
