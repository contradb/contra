// run with `yarn test`
import { SearchEx, FigureSearchEx } from "search-ex"

describe("x = toLisp of fromLisp of x", () => {
  ;[
    ["figure", "do si do"],
    ["figure", "swing", "partners", "*", 8],
    ["formation", "improper"],
    ["progression"],
    ["or", ["figure", "do si do"], ["figure", "swing"]],
    ["and", ["figure", "do si do"], ["figure", "swing"]],
    ["&", ["progression"], ["figure", "star"]],
    ["then", ["figure", "do si do"], ["figure", "swing"]],
    ["no", ["progression"]],
    ["not", ["figure", "do si do"]],
    ["all", ["figure", "do si do"]],
    ["count", ["progression"], ">", 0],
    ["compare", ["constant", 4], "<", ["constant", 6]],
    ["constant", 5],
    ["constant", 0],
    ["tag", "verified"],
    ["count-matches", ["figure", "*"]],
  ].forEach(function(lisp) {
    test(JSON.stringify(lisp), () =>
      expect(SearchEx.fromLisp(lisp).toLisp()).toEqual(lisp)
    )
  })
})

describe("cast", () => {
  ;[
    {
      op: "then",
      from: ["progression"],
      want: ["then", ["progression"], ["figure", "*"]],
    },
    {
      op: "then",
      from: ["not", ["progression"]],
      want: ["then", ["not", ["progression"]], ["figure", "*"]],
    },
    { op: "then", from: ["and"], want: ["then"] },
    {
      op: "then",
      from: ["and", ["progression"]],
      want: ["then", ["progression"]],
    },
    {
      op: "then",
      from: ["and", ["progression"], ["figure", "chain"]],
      want: ["then", ["progression"], ["figure", "chain"]],
    },
    {
      op: "and",
      from: ["figure", "swing"],
      want: ["and", ["figure", "swing"], ["figure", "*"]],
    },
    { op: "figure", from: ["and"], want: ["figure", "*"] },
    { op: "formation", from: ["and"], want: ["formation", "improper"] },
    { op: "progression", from: ["and"], want: ["progression"] },
    { op: "no", from: ["and"], want: ["no", ["and"]] },
    { op: "no", from: ["not", ["figure", "*"]], want: ["no", ["figure", "*"]] },
    {
      op: "no",
      from: ["or", ["figure", "swing"], ["figure", "chain"]],
      want: ["no", ["or", ["figure", "swing"], ["figure", "chain"]]],
    },
    { op: "not", from: ["and"], want: ["not", ["and"]] },
    {
      op: "not",
      from: ["no", ["figure", "*"]],
      want: ["not", ["figure", "*"]],
    },
    {
      op: "not",
      from: ["or", ["figure", "swing"], ["figure", "chain"]],
      want: ["not", ["or", ["figure", "swing"], ["figure", "chain"]]],
    },
    { op: "all", from: ["and"], want: ["all", ["and"]] },
    {
      op: "all",
      from: ["no", ["figure", "*"]],
      want: ["all", ["figure", "*"]],
    },
    {
      op: "all",
      from: ["or", ["figure", "swing"], ["figure", "chain"]],
      want: ["all", ["or", ["figure", "swing"], ["figure", "chain"]]],
    },
    { op: "count", from: ["and"], want: ["count", ["and"], ">", 0] },
    {
      op: "count",
      from: ["no", ["figure", "*"]],
      want: ["count", ["figure", "*"], ">", 0],
    },
    {
      op: "count",
      from: ["or", ["figure", "swing"], ["figure", "chain"]],
      want: ["count", ["or", ["figure", "swing"], ["figure", "chain"]], ">", 0],
    },
    {
      op: "compare",
      from: ["progression"],
      want: ["compare", ["constant", 0], ">", ["constant", 0]],
    },
    { op: "constant", from: ["tag", "verified"], want: ["constant", 0] },
    { op: "tag", from: ["constant", 7], want: ["tag", "verified"] },
    {
      op: "count-matches",
      from: ["constant", 7],
      want: ["count-matches", ["figure", "*"]],
    },
    {
      op: "progress with",
      from: ["not", ["figure", "star"]],
      want: ["progress with", ["figure", "star"]],
    },
  ].forEach(function({ from, op, want }, i) {
    const fromEx = SearchEx.fromLisp(from)
    const got = fromEx.castTo(op).toLisp()
    test(`${fromEx}.castTo('${op}') ≈> ${JSON.stringify(want)}`, () => {
      expect(got).toEqual(want)
    })
  })
})

describe("ellipsis", () => {
  test("with parameters specified, ellipsis is implicitly true", () => {
    const searchEx = new FigureSearchEx({
      move: "swing",
      parameters: ["*", "*", 8],
    })
    const bigLisp = ["figure", "swing", "*", "*", 8]
    expect(searchEx.toLisp()).toEqual(bigLisp)
    expect(searchEx.ellipsis).toEqual(true)
  })

  test("with parameters left off, ellipsis is implictly false", () => {
    const searchEx = new FigureSearchEx({ move: "swing" })
    const shortLisp = ["figure", "swing"]
    expect(searchEx.ellipsis).toEqual(false)
    expect(searchEx.toLisp()).toEqual(shortLisp)
  })

  test("with parameters specified and ellipsis specified false", () => {
    const searchEx = new FigureSearchEx({
      move: "swing",
      parameters: ["*", "*", 8],
      ellipsis: false,
    })
    const shortLisp = ["figure", "swing"]
    expect(searchEx.toLisp()).toEqual(shortLisp)
    expect(searchEx.ellipsis).toEqual(false)
  })

  test("with parameters left off and ellipsis specified true", () => {
    const searchEx = new FigureSearchEx({ move: "swing", ellipsis: true })
    const bigLisp = ["figure", "swing", "*", "*", "*"]
    expect(searchEx.ellipsis).toEqual(true)
    expect(searchEx.toLisp()).toEqual(bigLisp)
  })
})

test("copy", () => {
  const originalLisp = ["and", ["figure", "do si do"], ["figure", "swing"]]
  const original = SearchEx.fromLisp(originalLisp)
  const copy = original.copy()
  copy.subexpressions[0]._move = "circle" // hack the type for testing
  expect(copy.toLisp()).toEqual([
    "and",
    ["figure", "circle"],
    ["figure", "swing"],
  ])
  expect(original.toLisp()).toEqual(originalLisp)
  expect(originalLisp[1][1]).toEqual("do si do")
})

describe("isNumeric()", () => {
  ;[
    ["figure", "do si do"],
    ["figure", "swing", "partners", "*", 8],
    ["formation", "improper"],
    ["progression"],
    ["or", ["figure", "do si do"], ["figure", "swing"]],
    ["and", ["figure", "do si do"], ["figure", "swing"]],
    ["&", ["progression"], ["figure", "star"]],
    ["then", ["figure", "do si do"], ["figure", "swing"]],
    ["no", ["progression"]],
    ["not", ["figure", "do si do"]],
    ["all", ["figure", "do si do"]],
    ["count", ["progression"], ">", 0],
    ["compare", ["constant", 4], "<", ["constant", 6]],
    ["progress with", ["figure", "do si do"]],
  ].forEach(lisp => {
    test(JSON.stringify(lisp) + " → false", () =>
      expect(SearchEx.fromLisp(lisp).isNumeric()).toBe(false)
    )
  })
  ;[
    ["constant", 5],
    ["constant", 0],
    ["tag", "verified"],
    ["count-matches", ["figure", "*"]],
  ].forEach(lisp => {
    test(JSON.stringify(lisp) + " → true", () =>
      expect(SearchEx.fromLisp(lisp).isNumeric()).toBe(true)
    )
  })
})

describe("replace()", () => {
  it("depth 0 hit", () => {
    const oldRoot = SearchEx.fromLisp(["figure", "*"])
    const oldSub = oldRoot
    const newSub = SearchEx.fromLisp(["figure", "do si do"])
    const newRoot = oldRoot.replace(oldSub, newSub)
    expect(newRoot).toBe(newSub)
  })

  it("depth 0 miss", () => {
    const oldRoot = SearchEx.fromLisp(["figure", "*"])
    const oldSub = SearchEx.fromLisp(["figure", "swing"])
    const newSub = SearchEx.fromLisp(["figure", "do si do"])
    const newRoot = oldRoot.replace(oldSub, newSub)
    expect(newRoot).toBe(oldRoot)
  })

  it("depth 1 hit", () => {
    const oldRoot = SearchEx.fromLisp([
      "&",
      ["tag", "verified"],
      ["figure", "star"],
      ["progression"],
    ])
    const oldSub = oldRoot.subexpressions[1] // star
    const newSub = SearchEx.fromLisp(["figure", "do si do"])
    const newRoot = oldRoot.replace(oldSub, newSub)
    const expectedLisp = [
      "&",
      ["tag", "verified"],
      ["figure", "do si do"],
      ["progression"],
    ]
    expect(newRoot.toLisp()).toEqual(expectedLisp)
    expect(newRoot.subexpressions[0]).toBe(oldRoot.subexpressions[0])
    expect(newRoot.subexpressions[1]).toBe(newSub)
    expect(newRoot.subexpressions[2]).toBe(oldRoot.subexpressions[2])
    expect(newRoot.op).toEqual("&")
  })

  it("depth 1 miss", () => {
    const oldRoot = SearchEx.fromLisp([
      "&",
      ["tag", "verified"],
      ["figure", "star"],
      ["progression"],
    ])
    const oldSub = SearchEx.fromLisp(["figure", "star"]) // a different star
    const newSub = SearchEx.fromLisp(["figure", "do si do"])
    const expectedLisp = oldRoot.toLisp()
    const newRoot = oldRoot.replace(oldSub, newSub)
    expect(newRoot.toLisp()).toEqual(expectedLisp)
    expect(newRoot.subexpressions).toBe(oldRoot.subexpressions)
    expect(newRoot.op).toEqual("&")
  })
  it("depth 2 hit", () => {
    const oldRoot = SearchEx.fromLisp([
      "and",
      ["no", ["figure", "hey"]],
      ["no", ["figure", "star"]],
      ["no", ["figure", "circle"]],
    ])
    const oldSub = oldRoot.subexpressions[1].subexpressions[0] // star
    const newSub = SearchEx.fromLisp(["figure", "do si do"])
    const newRoot = oldRoot.replace(oldSub, newSub)
    const expectedLisp = [
      "and",
      ["no", ["figure", "hey"]],
      ["no", ["figure", "do si do"]],
      ["no", ["figure", "circle"]],
    ]
    expect(oldSub.move).toBe("star")
    expect(newRoot.toLisp()).toEqual(expectedLisp)
    expect(newRoot.subexpressions[0]).toBe(oldRoot.subexpressions[0])
    expect(newRoot.subexpressions[1].op).toEqual("no")
    expect(newRoot.subexpressions[1].subexpressions[0]).toBe(newSub)
    expect(newRoot.subexpressions[1].subexpressions.length).toBe(1)
    expect(newRoot.subexpressions[2]).toBe(oldRoot.subexpressions[2])
  })
})

describe("remove()", () => {
  it("depth 0 hit", () => {
    const oldRoot = SearchEx.fromLisp(["figure", "*"])
    const oldSub = oldRoot
    expect(() => oldRoot.remove(oldSub)).toThrowError("attempt to remove self")
  })

  it("depth 0 miss", () => {
    const oldRoot = SearchEx.fromLisp(["figure", "*"])
    const oldSub = SearchEx.fromLisp(["figure", "swing"])
    const newRoot = oldRoot.remove(oldSub)
    expect(newRoot).toBe(oldRoot)
  })

  it("depth 1 hit", () => {
    const oldRoot = SearchEx.fromLisp([
      "&",
      ["tag", "verified"],
      ["figure", "star"],
      ["progression"],
    ])
    const oldSub = oldRoot.subexpressions[1] // star
    const newRoot = oldRoot.remove(oldSub)
    const expectedLisp = ["&", ["tag", "verified"], ["progression"]]
    expect(newRoot.toLisp()).toEqual(expectedLisp)
    expect(newRoot.subexpressions[0]).toBe(oldRoot.subexpressions[0])
    expect(newRoot.subexpressions[1]).toBe(oldRoot.subexpressions[2])
    expect(newRoot.op).toEqual("&")
  })

  it("depth 1 miss", () => {
    const oldRoot = SearchEx.fromLisp([
      "&",
      ["tag", "verified"],
      ["figure", "star"],
      ["progression"],
    ])
    const oldSub = SearchEx.fromLisp(["figure", "star"]) // a different star
    const expectedLisp = oldRoot.toLisp()
    const newRoot = oldRoot.remove(oldSub)
    expect(newRoot.toLisp()).toEqual(expectedLisp)
    expect(newRoot.subexpressions).toBe(oldRoot.subexpressions)
    expect(newRoot.op).toEqual("&")
  })

  it("depth 2 hit", () => {
    const oldRoot = SearchEx.fromLisp([
      "and",
      ["no", ["figure", "hey"]],
      ["or", ["figure", "star"]],
      ["no", ["figure", "circle"]],
    ])
    const oldSub = oldRoot.subexpressions[1].subexpressions[0] // star
    const newRoot = oldRoot.remove(oldSub)
    const expectedLisp = [
      "and",
      ["no", ["figure", "hey"]],
      ["or"],
      ["no", ["figure", "circle"]],
    ]
    expect(oldSub.move).toBe("star")
    expect(newRoot.toLisp()).toEqual(expectedLisp)
    expect(newRoot.subexpressions[0]).toBe(oldRoot.subexpressions[0])
    expect(newRoot.subexpressions[2]).toBe(oldRoot.subexpressions[2])
  })
})

describe("shallowCopy", () => {
  // operators with no instance variables (besides subexpressions)
  for (const op of [
    "no",
    "not",
    "all",
    "and",
    "or",
    "&",
    "then",
    "progression",
    "count-matches",
    "progress with",
  ]) {
    describe(op, () => {
      it("copies", () => {
        const oldEx = SearchEx.fromLisp([op, ["progression"]])
        const newEx = oldEx.shallowCopy()
        expect(oldEx).not.toBe(newEx)
        expect(newEx.subexpressions).toEqual(oldEx.subexpressions)
        expect(newEx.subexpressions).not.toBe(oldEx.subexpressions)
      })

      it("takes arg", () => {
        const figure = SearchEx.fromLisp(["figure", "*"])
        const oldEx = SearchEx.fromLisp([op, ["progression"]])
        const newEx = oldEx.shallowCopy({
          subexpressions: [figure],
        })
        expect(oldEx).not.toBe(newEx)
        expect(newEx.op).toEqual(op)
        expect(newEx.subexpressions).not.toBe(oldEx.subexpressions)
        expect(newEx.subexpressions).toEqual([figure])
        expect(newEx.subexpressions[0]).toBe(figure)
      })
    })
  }

  describe("figure", () => {
    it("move", () => {
      const oldEx = SearchEx.fromLisp([
        "figure",
        "do si do",
        "ladles",
        true,
        540,
        8,
      ])
      const newEx = oldEx.shallowCopy({ move: "allemande" })
      expect(newEx.subexpressions).not.toBe(oldEx.subExpressions)
      expect(newEx.move).toEqual("allemande")
      expect(newEx.parameters).not.toBe(oldEx.parameters)
      expect(newEx.parameters).toEqual(["*", "*", "*", "*"])
    })
    it("parameters", () => {
      const oldEx = SearchEx.fromLisp([
        "figure",
        "do si do",
        "ladles",
        true,
        540,
        8,
      ])
      const newEx = oldEx.shallowCopy({
        parameters: ["gentlespoons", true, "*", 8],
      })
      expect(newEx.subexpressions).not.toBe(oldEx.subExpressions)
      expect(newEx.move).toBe(oldEx.move)
      expect(newEx.parameters).not.toBe(oldEx.parameters)
      expect(newEx.parameters).toEqual(["gentlespoons", true, "*", 8])
    })
    describe("ellipsis", () => {
      it("false", () => {
        const oldEx = new FigureSearchEx({
          move: "swing",
          parameters: ["*", "*", 8],
        })
        expect(oldEx.ellipsis).toBe(true)
        const newEx = oldEx.shallowCopy({ ellipsis: false })
        expect(newEx.subexpressions).not.toBe(oldEx.subExpressions)
        expect(newEx.move).toBe(oldEx.move)
        expect(newEx.parameters).toEqual(oldEx.parameters)
        expect(newEx.ellipsis).toBe(false)
      })
      it("true", () => {
        const oldEx = new FigureSearchEx({
          move: "swing",
        })
        expect(oldEx.ellipsis).toBe(false)
        expect(oldEx.parameters).toEqual([])
        const newEx = oldEx.shallowCopy({ ellipsis: true })
        expect(newEx.subexpressions).not.toBe(oldEx.subExpressions)
        expect(newEx.move).toBe(oldEx.move)
        expect(newEx.parameters).toEqual(["*", "*", "*"])
        expect(newEx.ellipsis).toBe(true)
      })
      it("true copying interesting parameters", () => {
        const oldEx = new FigureSearchEx({
          move: "swing",
          parameters: ["*", "*", 8],
          ellipsis: false,
        })
        expect(oldEx.ellipsis).toBe(false)
        expect(oldEx.parameters.length).toEqual(3)
        const newEx = oldEx.shallowCopy({ ellipsis: true })
        expect(newEx.subexpressions).not.toBe(oldEx.subExpressions)
        expect(newEx.move).toBe(oldEx.move)
        expect(newEx.parameters).toEqual(["*", "*", 8])
        expect(newEx.ellipsis).toBe(true)
      })

      it("true, passing text parameters as '' and not '*'", () => {
        const oldEx = new FigureSearchEx({
          move: "custom",
          ellipsis: false,
        })
        expect(oldEx.ellipsis).toBe(false)
        const newEx = oldEx.shallowCopy({ ellipsis: true })
        expect(newEx.subexpressions).not.toBe(oldEx.subExpressions)
        expect(newEx.move).toBe(oldEx.move)
        expect(newEx.parameters).toEqual(["", "*"])
        expect(newEx.ellipsis).toBe(true)
      })

      it("true, picking up specifics from alias instead of '*'", () => {
        const oldEx = new FigureSearchEx({
          move: "see saw",
          ellipsis: false,
        })
        expect(oldEx.ellipsis).toBe(false)
        const newEx = oldEx.shallowCopy({ ellipsis: true })
        expect(newEx.subexpressions).not.toBe(oldEx.subExpressions)
        expect(newEx.move).toBe(oldEx.move)
        expect(newEx.parameters).toEqual(["*", false, "*", "*"])
        expect(newEx.ellipsis).toBe(true)
      })
    })
  })

  describe("formation", () => {
    it("copies", () => {
      const oldEx = SearchEx.fromLisp(["formation", "improper"])
      const newEx = oldEx.shallowCopy()
      expect(oldEx).not.toBe(newEx)
      expect(newEx.subexpressions).not.toBe(oldEx.subexpressions)
      expect(newEx.formation).toEqual(oldEx.formation)
    })
    it("takes arg", () => {
      const oldEx = SearchEx.fromLisp(["formation", "improper"])
      const newEx = oldEx.shallowCopy({ formation: "Becket" })
      expect(oldEx).not.toBe(newEx)
      expect(newEx.subexpressions).not.toBe(oldEx.subexpressions)
      expect(newEx.formation).toEqual("Becket")
    })
  })

  describe("compare", () => {
    it("comparison", () => {
      const oldEx = SearchEx.fromLisp([
        "compare",
        ["count-matches", ["figure", "*"]],
        "<",
        ["constant", 6],
      ])
      const newEx = oldEx.shallowCopy({ comparison: "=" })
      expect(newEx.subexpressions).toEqual(oldEx.subexpressions)
      expect(newEx.subexpressions).not.toBe(oldEx.subexpressions)
      expect(newEx.left).toBe(oldEx.left)
      expect(newEx.right).toBe(oldEx.right)
      expect(newEx.comparison).toEqual("=")
    })
    it("subexpressions", () => {
      const oldEx = SearchEx.fromLisp([
        "compare",
        ["count-matches", ["figure", "*"]],
        "<",
        ["constant", 6],
      ])
      const newSubexpressions = [
        ["count-matches", ["figure", "do si do"]],
        ["constant", 2],
      ].map(SearchEx.fromLisp)
      const newEx = oldEx.shallowCopy({
        subexpressions: newSubexpressions,
      })
      expect(newEx.subexpressions).not.toBe(oldEx.subExpressions)
      expect(newEx.comparison).toBe(oldEx.comparison)
      expect(newEx.subexpressions).toBe(newSubexpressions)
    })
  })

  describe("constant", () => {
    it("copies", () => {
      const oldEx = SearchEx.fromLisp(["constant", 23])
      const newEx = oldEx.shallowCopy()
      expect(oldEx).not.toBe(newEx)
      expect(newEx.subexpressions).not.toBe(oldEx.subexpressions)
      expect(newEx.number).toEqual(oldEx.number)
    })
    it("takes arg", () => {
      const oldEx = SearchEx.fromLisp(["constant", 23])
      const newEx = oldEx.shallowCopy({ number: 17 })
      expect(oldEx).not.toBe(newEx)
      expect(newEx.subexpressions).not.toBe(oldEx.subexpressions)
      expect(newEx.number).toEqual(17)
    })
  })

  describe("tag", () => {
    it("copies", () => {
      const oldEx = SearchEx.fromLisp(["tag", "verified"])
      const newEx = oldEx.shallowCopy()
      expect(oldEx).not.toBe(newEx)
      expect(newEx.subexpressions).not.toBe(oldEx.subexpressions)
      expect(newEx.tag).toEqual(oldEx.tag)
    })
    it("takes arg", () => {
      const oldEx = SearchEx.fromLisp(["tag", "verified"])
      const newEx = oldEx.shallowCopy({ tag: "hard" })
      expect(oldEx).not.toBe(newEx)
      expect(newEx.subexpressions).not.toBe(oldEx.subexpressions)
      expect(newEx.tag).toEqual("hard")
    })
  })
})

describe("withAdditionalSubexpression", () => {
  it("adds SearchEx.default() with no argument", () => {
    const elisp = ["and", ["figure", "swing"]]
    const e = SearchEx.fromLisp(elisp)
    const e2 = e.withAdditionalSubexpression()
    expect(e2.toLisp()).toEqual([...elisp, SearchEx.default().toLisp()])
    expect(e2.subexpressions[0]).toBe(e.subexpressions[0])
  })

  it("adds an optional parameter", () => {
    const elisp = ["and", ["figure", "swing"]]
    const e = SearchEx.fromLisp(elisp)
    const extra = SearchEx.fromLisp(["figure", "do si do"])
    const e2 = e.withAdditionalSubexpression(extra)
    expect(e2.toLisp()).toEqual([...elisp, extra.toLisp()])
    expect(e2.subexpressions[0]).toBe(e.subexpressions[0])
    expect(e2.subexpressions[1]).toBe(extra)
  })

  it("throws when there is no space", () => {
    const se = SearchEx.fromLisp(["figure", "swing"])
    const msg = "subexpressions are full"
    expect(() => se.withAdditionalSubexpression()).toThrowError(msg)
  })
})

describe("alias parameters can dealias moves", () => {
  it("move changes if parameters are completely outside of alias", () => {
    const doSiDo = new FigureSearchEx({
      move: "see saw",
      parameters: ["*", true, "*", "*"],
      ellipsis: true,
    })
    expect(doSiDo.move).toBe("do si do")
  })
  it("move changes if parameters are broader than alias", () => {
    const doSiDo = new FigureSearchEx({
      move: "see saw",
      parameters: ["*", "*", "*", "*"],
      ellipsis: true,
    })
    expect(doSiDo.move).toBe("do si do")
  })
  it("move stays the same if parameters are within specific alias", () => {
    const doSiDo = new FigureSearchEx({
      move: "see saw",
      parameters: ["*", false, "*", "*"],
      ellipsis: true,
    })
    expect(doSiDo.move).toBe("see saw")
  })
  it("move stays the same if parameters are within wildcard alias", () => {
    const doSiDo = new FigureSearchEx({
      move: "see saw",
      parameters: ["*", false, "*", 8],
      ellipsis: true,
    })
    expect(doSiDo.move).toBe("see saw")
  })
})

describe("toJson and fromJson", () => {
  it("works", () => {
    const searchEx = SearchEx.fromLisp(["figure", "do si do"])
    expect(SearchEx.fromJson(searchEx.toJson())).toEqual(searchEx)
  })
})
