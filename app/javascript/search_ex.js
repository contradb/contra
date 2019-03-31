// search node class heirarchy goes here
class  SearchEx {
  constructor({subexpressions = []} = {}) {
    this.subexpressions = subexpressions;
  }
  // subtypes to implement: toLisp() and static fromLispHelper(...)
  op() {
    return constructorNameToOp[this.constructor.name];
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
};

function registerSearchEx(className) {
  const op = className.replace(/SearchEx$/, '').toLowerCase().replace(/ampersand/g, '&');
  constructorNameToOp[className] = op;
  opToConstructor[op] = eval(className);
  if (!opToConstructor[op]) {
    throw new Error('class name ' + className + ' not found');
  }
}

const opToConstructor = {};
const constructorNameToOp = {};

function errorMissingParameter(name) {
  throw new Error('missing parameter "'+name+'"');
}

let nullaryMixin = Base => class extends Base {
  max_subexpressions() { return 0; }
  min_subexpressions() { return 0; }
  min_useful_subexpressions() { return 0; };
}

let unaryMixin = Base => class extends Base {
  max_subexpressions() { return 1; }
  min_subexpressions() { return 1; }
  min_useful_subexpressions() { return 1; };
}

let binaryishMixin = Base => class extends Base {
  max_subexpressions() { return Infinity; }
  min_subexpressions() { return 0; }
  min_useful_subexpressions() { return 2; };
}

class FigureSearchEx extends nullaryMixin(SearchEx) {
  constructor(args) {
    super(args);
    const {move, parameters = []} = args;
    this.move = move || errorMissingParameter('move');
    this.parameters = parameters;
  };
  toLisp() {
    return [this.op(), this.move, ...this.parameters];
  }
  static fromLispHelper(constructor, lisp) {
    return new constructor({move: lisp[1], parameters: lisp.slice(2)});
  }
};
registerSearchEx('FigureSearchEx');

class FormationSearchEx extends nullaryMixin(SearchEx) {
  constructor(args) {
    super(args);
    const {formation} = args;
    this.formation = formation || errorMissingParameter('formation');
  };
  toLisp() {
    return [this.op(), this.formation];
  }
};
registerSearchEx('FormationSearchEx');

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
    return [this.op(), ...this.subexpressions.map(sex => sex.toLisp())];
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
class AmpersandSearchEx extends SimpleBinaryishSearchEx {}; registerSearchEx('AmpersandSearchEx');
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
    console.log(lisp, number);
    return new constructor({subexpressions: [SearchEx.fromLisp(subexpression)], comparison: comparison, number: number});
  }
}
registerSearchEx('CountSearchEx');


function test() {
  let errors = [];

  function lispEquals(lisp1, lisp2) {
    return JSON.stringify(lisp1) === JSON.stringify(lisp2);
  }

  [['figure', 'do si do'],
   ['figure', 'swing', 'partners', '*', 8],
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
    throw new Error('tests ' + JSON.stringify(errors) + ' failed');
  } else {
    return 'tests pass';
  }
}

test();

// new FigureSearchEx({subexpressions: 'foo', figure: 'do si do', parameters: [8]});

        // figure
        // formation
        // progression
        // or
        // and
        // &
        // then
        // no
        // not ('anything but' in UI)
        // all
        // count ('number of' in UI)
