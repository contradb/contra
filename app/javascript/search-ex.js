import LibFigure from "libfigure/libfigure.js"

// search node class heirarchy goes here
class SearchEx {
  // subtypes to implement:
  // toLisp()
  // static fromLispHelper(...)
  // static castFrom()
  // static minSubexpressions()
  // static maxSubexpressions()
  // static minUsefulSubexpressions()
  // 'src' constructor prop

  constructor({
    src,
    subexpressions = src ? [...src.subexpressions] : [],
  } = {}) {
    this.subexpressions = subexpressions
  }

  shallowCopy(props) {
    return new this.constructor({ ...props, src: this })
  }

  get op() {
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
    // deeeep copy - am I even used?
    return SearchEx.fromLisp(this.toLisp())
  }

  static allProps() {
    // all properties held by any subclass.
    return allProps
  }

  isNumeric() {
    return false
  }

  replace(oldEx, newEx) {
    if (this === oldEx) return newEx
    else {
      for (let i = 0; i < this.subexpressions.length; i++) {
        const subexpressionOld = this.subexpressions[i]
        const subexpressionNew = subexpressionOld.replace(oldEx, newEx)
        if (subexpressionOld !== subexpressionNew) {
          const newChildren = [...this.subexpressions]
          newChildren[i] = subexpressionNew
          for (let j = i + 1; j < this.subexpressions.length; j++)
            newChildren[j] = this.subexpressions[j].replace(oldEx, newEx)
          return this.shallowCopy({ subexpressions: newChildren })
        }
      }
      return this
    }
  }

  remove(oldEx) {
    return removeHelper(this, oldEx, throwRemoveError)
  }

  withAdditionalSubexpression(e = SearchEx.default()) {
    if (this.subexpressions.length < this.maxSubexpressions())
      return this.shallowCopy({
        subexpressions: [...this.subexpressions, e],
      })
    else throw new Error("subexpressions are full")
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
  op = op.replace(/ProgressWith/, "progress with")
  op = op.toLowerCase()
  constructorNameToOp[className] = op
  const constructor = eval(className)
  if (!constructor) {
    throw new Error("class name " + className + " not found")
  }
  opToConstructor[op] = constructor
  constructor.name2 = className
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

const removeHelper = (root, target, rootHit) => {
  if (root === target) return rootHit()
  else {
    const sube = root.subexpressions.map(e =>
      removeHelper(e, target, constantlyNull)
    )
    let different = false
    for (let i = 0; i < sube.length; i++) {
      if (root.subexpressions[i] !== sube[i]) {
        different = true
        break
      }
    }
    if (different)
      return root.shallowCopy({ subexpressions: sube.filter(e => e) })
    else return root
  }
  return root
}

const throwRemoveError = () => {
  throw new Error("attempt to remove self is not allowed")
}

const constantlyNull = () => null

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
    const {
      src,
      move = src ? src.move : errorMissingParameter("move"),
      parameters = src && src.move === move ? [...src.parameters] : [],
      ellipsis = src ? src.ellipsis : parameters && parameters.length > 0,
    } = args
    const isAlias = move !== "*" && LibFigure.isAlias(move)
    const aliasFilter = isAlias ? LibFigure.aliasFilter(move) : []
    let massagedMove = move
    if (isAlias) {
      // set move to something less specific, if the params are wider
      for (let i = 0; i < parameters.length && i < aliasFilter.length; i++) {
        const parameter = parameters[i]
        const aliasF = aliasFilter[i]
        if (parameter != aliasF && aliasF != "*") {
          massagedMove = LibFigure.deAliasMove(move)
          break
        }
      }
    }
    this._move = massagedMove
    this._parameters = parameters
    this._ellipsis = ellipsis

    // initialize parameters
    if (0 === parameters.length && ellipsis && this.move !== "*") {
      const formals = LibFigure.formalParameters(this.move)
      this._parameters = [...this.parameters]
      while (this.parameters.length < formals.length) {
        if (this.parameters.length < aliasFilter.length) {
          this.parameters.push(aliasFilter[this.parameters.length])
        } else {
          const formalIsText =
            formals[this.parameters.length].ui.name == "chooser_text"
          this.parameters.push(formalIsText ? "" : "*")
        }
      }
    }
  }

  toLisp() {
    if (this.ellipsis) {
      return [this.op, this.move, ...this.parameters]
    } else {
      return [this.op, this.move]
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

  get parameters() {
    return this._parameters
  }

  get ellipsis() {
    return this._ellipsis
  }
}
registerSearchEx("FigureSearchEx", "move", "parameters", "ellipsis")

class FormationSearchEx extends nullaryMixin(SearchEx) {
  constructor(args) {
    super(args)
    const { formation, src } = args
    this.formation =
      formation || src.formation || errorMissingParameter("formation")
  }

  toLisp() {
    return [this.op, this.formation]
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
    return [this.op]
  }

  static fromLispHelper(constructor, lisp) {
    return new constructor()
  }
}
registerSearchEx("ProgressionSearchEx")

class SimpleUnarySearchEx extends unaryMixin(SearchEx) {
  toLisp() {
    return [this.op, this.subexpressions[0].toLisp()]
  }

  static fromLispHelper(constructor, lisp) {
    return new constructor({ subexpressions: [SearchEx.fromLisp(lisp[1])] })
  }
}

// expressions that take just other SearchEx's and no other things.
class SimpleBinaryishSearchEx extends binaryishMixin(SearchEx) {
  toLisp() {
    return [this.op, ...this.subexpressions.map(searchEx => searchEx.toLisp())]
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

// obsolete
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
      this.op,
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
    const { comparison, src } = args
    this.comparison =
      comparison || src.comparison || errorMissingParameter("comparison")
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
    return [this.op, this.left.toLisp(), this.comparison, this.right.toLisp()]
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
    const { number, src } = args
    if (number || 0 === number) {
      this.number = number
    } else if (src && (src.number || 0 === src.number)) {
      this.number = src.number
    } else {
      errorMissingParameter("number")
    }
  }

  static fromLispHelper(constructor, lisp) {
    return new constructor({ number: lisp[1] })
  }

  toLisp() {
    return [this.op, this.number]
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
    const { tag, src } = args
    this.tag = tag || src.tag || errorMissingParameter("tag")
  }

  static fromLispHelper(constructor, lisp) {
    return new constructor({ tag: lisp[1] })
  }

  toLisp() {
    return [this.op, this.tag]
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
    return [this.op, this.subexpressions[0].toLisp()]
  }

  static castFrom(searchEx) {
    return new this({ subexpressions: [SearchEx.default()] })
  }
}
registerSearchEx("CountMatchesNumericEx")

export { SearchEx, NumericEx, FigureSearchEx }

class ProgressWithSearchEx extends SimpleUnarySearchEx {}
registerSearchEx("ProgressWithSearchEx")
