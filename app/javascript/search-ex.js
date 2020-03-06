import LibFigure from "libfigure/libfigure.js"

// search node class heirarchy goes here
class SearchEx {
  constructor({ subexpressions = [] } = {}) {
    this.subexpressions = subexpressions
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
    return constructorNameToOp[this.constructor.name2]
  }
  static fromLisp(lisp) {
    const constructor = opToConstructor[lisp[0]]
    if (!constructor) {
      throw new Error(
        "lisp doesn't appear to start with an op: " + JSON.stringify(lisp)
      )
    } else if (!constructor.fromLispHelper) {
      throw new Error(
        "must go implement fromLispHelper for some superclass of '" +
          lisp[0] +
          "'"
      )
    } else {
      return constructor.fromLispHelper(constructor, lisp)
    }
  }
  castTo(op) {
    return opToConstructor[op].castFrom(this)
  }
  static default() {
    return SearchEx.fromLisp(["figure", "*"])
  }
  minSubexpressions() {
    return this.constructor.minSubexpressions()
  }
  maxSubexpressions() {
    return this.constructor.maxSubexpressions()
  }
  minUsefulSubexpressions() {
    return this.constructor.minUsefulSubexpressions()
  }

  copy() {
    // deeeep copy
    return SearchEx.fromLisp(this.toLisp())
  }

  static allProps() {
    // all properties held by any subclass.
    return allProps
  }
  isNumeric() {
    return false
  }

  static mutationNameForProp(propertyName) {
    if (propertyName.length >= 1) {
      return (
        "set" + propertyName.charAt(0).toUpperCase() + propertyName.slice(1)
      )
    } else {
      throw new Error("propertyName is too short")
    }
  }

  toString() {
    return `#<${this.constructor.name2} ${JSON.stringify(this.toLisp())}>`
  }
}

function registerSearchEx(className, ...props) {
  var op = className
  op = op.replace(/SearchEx$/, "")
  op = op.replace(/NumericEx$/, "")
  op = op.replace(/FigurewiseAnd/g, "&")
  op = op.replace(/CountMatches/, "count-matches")
  op = op.toLowerCase()
  constructorNameToOp[className] = op
  const constructor = eval(className)
  opToConstructor[op] = constructor
  constructor.name2 = className
  if (!opToConstructor[op]) {
    throw new Error("class name " + className + " not found")
  }
  for (let prop of props) {
    if (!allProps.includes(prop)) {
      allProps.push(prop)
    }
  }
}

const opToConstructor = {}
const constructorNameToOp = {}
const allProps = []

registerSearchEx("SearchEx", "subexpressions")

function errorMissingParameter(name) {
  throw new Error('missing parameter "' + name + '"')
}

let nullaryMixin = Base =>
  class extends Base {
    static maxSubexpressions() {
      return 0
    }
    static minSubexpressions() {
      return 0
    }
    static minUsefulSubexpressions() {
      return 0
    }
    static castFrom(searchEx) {
      return new this()
    }
  }

let unaryMixin = Base =>
  class extends Base {
    static maxSubexpressions() {
      return 1
    }
    static minSubexpressions() {
      return 1
    }
    static minUsefulSubexpressions() {
      return 1
    }
    static castFrom(searchEx) {
      return new this(this.castConstructorDefaults(searchEx))
    }
    static castConstructorDefaults(searchEx) {
      return {
        subexpressions:
          1 === searchEx.subexpressions.length
            ? searchEx.subexpressions
            : [searchEx],
      }
    }
  }

let binaryishMixin = Base =>
  class extends Base {
    static maxSubexpressions() {
      return Infinity
    }
    static minSubexpressions() {
      return 0
    }
    static minUsefulSubexpressions() {
      return 2
    }
    static castFrom(searchEx) {
      if (
        0 === searchEx.minSubexpressions() &&
        searchEx.maxSubexpressions() > 0
      ) {
        return new this({ subexpressions: searchEx.subexpressions })
      } else {
        const ses = [searchEx]
        while (ses.length < this.minUsefulSubexpressions()) {
          ses.push(SearchEx.default())
        }
        return new this({ subexpressions: ses })
      }
    }
  }

class FigureSearchEx extends nullaryMixin(SearchEx) {
  constructor(args) {
    super(args)
    const { move, parameters = [] } = args
    this._move = move || errorMissingParameter("move")
    this.parameters = parameters
    this._ellipsis = parameters && parameters.length > 0
  }
  toLisp() {
    if (this.ellipsis) {
      return [this.op(), this.move, ...this.parameters]
    } else {
      return [this.op(), this.move]
    }
  }
  static fromLispHelper(constructor, lisp) {
    return new constructor({ move: lisp[1], parameters: lisp.slice(2) })
  }
  static castFrom(searchEx) {
    return new this({ move: "*" })
  }
  get move() {
    return this._move
  }
  set move(moveString) {
    this._move = moveString
    this.parameters.length = 0
    this.padMissingParametersWithAsterisks()
  }
  get ellipsis() {
    return this._ellipsis
  }
  set ellipsis(expanded) {
    this._ellipsis = expanded
    this.padMissingParametersWithAsterisks()
  }
  padMissingParametersWithAsterisks() {
    if (this.ellipsis) {
      const formals_length = LibFigure.formalParameters(this.move).length
      while (this.parameters.length < formals_length) this.parameters.push("*")
    }
  }
}
registerSearchEx("FigureSearchEx", "move", "parameters", "ellipsis")

class FormationSearchEx extends nullaryMixin(SearchEx) {
  constructor(args) {
    super(args)
    const { formation } = args
    this.formation = formation || errorMissingParameter("formation")
  }
  toLisp() {
    return [this.op(), this.formation]
  }
  static fromLispHelper(constructor, lisp) {
    return new constructor({ formation: lisp[1] })
  }
  static castFrom(searchEx) {
    return new this({ formation: "improper" })
  }
}
registerSearchEx("FormationSearchEx", "formation")

class ProgressionSearchEx extends nullaryMixin(SearchEx) {
  toLisp() {
    return [this.op()]
  }
  static fromLispHelper(constructor, lisp) {
    return new constructor()
  }
}
registerSearchEx("ProgressionSearchEx")

class SimpleUnarySearchEx extends unaryMixin(SearchEx) {
  toLisp() {
    return [this.op(), this.subexpressions[0].toLisp()]
  }
  static fromLispHelper(constructor, lisp) {
    return new constructor({ subexpressions: [SearchEx.fromLisp(lisp[1])] })
  }
}

// expressions that take just other SearchEx's and no other things.
class SimpleBinaryishSearchEx extends binaryishMixin(SearchEx) {
  toLisp() {
    return [
      this.op(),
      ...this.subexpressions.map(searchEx => searchEx.toLisp()),
    ]
  }
  static fromLispHelper(constructor, lisp) {
    return new constructor({
      subexpressions: lisp.slice(1).map(SearchEx.fromLisp),
    })
  }
}

class NoSearchEx extends SimpleUnarySearchEx {}
registerSearchEx("NoSearchEx")
class NotSearchEx extends SimpleUnarySearchEx {}
registerSearchEx("NotSearchEx")
class AllSearchEx extends SimpleUnarySearchEx {}
registerSearchEx("AllSearchEx")

class AndSearchEx extends SimpleBinaryishSearchEx {}
registerSearchEx("AndSearchEx")
class OrSearchEx extends SimpleBinaryishSearchEx {}
registerSearchEx("OrSearchEx")
class FigurewiseAndSearchEx extends SimpleBinaryishSearchEx {}
registerSearchEx("FigurewiseAndSearchEx")
class ThenSearchEx extends SimpleBinaryishSearchEx {}
registerSearchEx("ThenSearchEx")

class CountSearchEx extends unaryMixin(SearchEx) {
  constructor(args) {
    super(args)
    const { comparison, number } = args
    this.comparison = comparison || errorMissingParameter("comparison")
    number !== undefined || errorMissingParameter("number")
    this.number = number
  }
  toLisp() {
    return [
      this.op(),
      this.subexpressions[0].toLisp(),
      this.comparison,
      this.number,
    ]
  }
  static fromLispHelper(constructor, lisp) {
    const [_op, subexpression, comparison, number] = lisp
    return new constructor({
      subexpressions: [SearchEx.fromLisp(subexpression)],
      comparison: comparison,
      number: number,
    })
  }
  static castConstructorDefaults(searchEx) {
    return {
      comparison: ">",
      number: 0,
      ...super.castConstructorDefaults(searchEx),
    }
  }
}
registerSearchEx("CountSearchEx", "comparison", "number")

class CompareSearchEx extends SearchEx {
  constructor(args) {
    super(args)
    const { comparison } = args
    this.comparison = comparison || errorMissingParameter("comparison")
    if (this.subexpressions.length !== 2) {
      throw new Error(
        `new CompareSearchEx wants exactly 2 subexpressions, but got ${JSON.stringify(
          this.subexpressions
        )}`
      )
    }
  }
  get left() {
    return this.subexpressions[0]
  }
  get right() {
    return this.subexpressions[1]
  }
  toLisp() {
    return [this.op(), this.left.toLisp(), this.comparison, this.right.toLisp()]
  }
  static fromLispHelper(constructor, lisp) {
    const [_op, left, comparison, right] = lisp
    return new constructor({
      comparison: comparison,
      subexpressions: [SearchEx.fromLisp(left), SearchEx.fromLisp(right)],
    })
  }
  static castFrom(searchEx) {
    return new this({
      comparison: searchEx.comparison || ">",
      subexpressions: [
        new ConstantNumericEx({ number: 0 }),
        new ConstantNumericEx({ number: 0 }),
      ],
    })
  }
  static minSubexpressions() {
    return 2
  }
  static maxSubexpressions() {
    return 2
  }
  static minUsefulSubexpressions() {
    return 2
  }
}
registerSearchEx("CompareSearchEx", "comparison")

class NumericEx extends SearchEx {
  isNumeric() {
    return true
  }
}

class ConstantNumericEx extends NumericEx {
  constructor(args) {
    super(args)
    let number = args.number
    if (!number && 0 !== number) errorMissingParameter("number")
    this.number = number
  }
  static fromLispHelper(constructor, lisp) {
    return new constructor({ number: lisp[1] })
  }
  toLisp() {
    return [this.op(), this.number]
  }
  static castFrom(searchEx) {
    return new this({ number: 0 })
  }
  static minSubexpressions() {
    return 0
  }
  static maxSubexpressions() {
    return 0
  }
  static minUsefulSubexpressions() {
    return 0
  }
}
registerSearchEx("ConstantNumericEx", "number")

class TagNumericEx extends NumericEx {
  constructor(args) {
    super(args)
    let tag = args.tag
    if (!tag) errorMissingParameter("tag")
    this.tag = tag
  }
  static fromLispHelper(constructor, lisp) {
    return new constructor({ tag: lisp[1] })
  }
  toLisp() {
    return [this.op(), this.tag]
  }
  static castFrom(searchEx) {
    return new this({ tag: "verified" })
  }
  static minSubexpressions() {
    return 0
  }
  static maxSubexpressions() {
    return 0
  }
  static minUsefulSubexpressions() {
    return 0
  }
}
registerSearchEx("TagNumericEx", "tag")

class CountMatchesNumericEx extends unaryMixin(NumericEx) {
  static fromLispHelper(constructor, lisp) {
    return new constructor({ subexpressions: [SearchEx.fromLisp(lisp[1])] })
  }
  toLisp() {
    return [this.op(), this.subexpressions[0].toLisp()]
  }
  static castFrom(searchEx) {
    return new this({ subexpressions: [SearchEx.default()] })
  }
}
registerSearchEx("CountMatchesNumericEx")

export { SearchEx, NumericEx, FigureSearchEx }
