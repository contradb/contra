import React from "react"
import { SearchEx, FigureSearchEx } from "./search-ex"

const makeOpOption = (op: string, i: number) => {
  if (op === "____")
    return (
      <option key={i} style={{ backgroundColor: "white" }} disabled>
        ————————
      </option>
    )
  else
    return (
      <option key={i} value={op}>
        {op.replace(/-/, " ")}
      </option>
    )
}

const nonNumericOpOptions = [
  "figure",
  "or",
  "and",
  "then",
  "no",
  "not",
  "all",
  "progress with",
  "____",
  "&",
  "progression",
  "compare",
  "formation",
].map(makeOpOption)

const numericOpOptions = ["constant", "tag", "count-matches"].map(makeOpOption)

export const SearchExEditor = ({
  searchEx,
  setSearchEx,
  removeSearchEx,
}: {
  searchEx: SearchEx
  setSearchEx: (se: SearchEx) => void
  removeSearchEx: null | ((se: SearchEx) => void)
}) => {
  const hasEnoughChildrenToRemoveOne =
    searchEx.subexpressions.length > searchEx.minSubexpressions()
  const subexpressionRemoveFn = hasEnoughChildrenToRemoveOne
    ? (sub: SearchEx) => setSearchEx(searchEx.remove(sub))
    : null
  const subexpressionsGrowFn = () =>
    setSearchEx(searchEx.withAdditionalSubexpression())
  return (
    <div className="search-ex">
      <div className="search-ex-well">
        <div className="search-ex-trunk">
          <div className="form-inline">
            <select
              value={searchEx.op()}
              onChange={e => {
                const op = e.target.value
                setSearchEx(searchEx.castTo(op))
              }}
              className="form-control search-ex-op"
            >
              {searchEx.isNumeric() ? numericOpOptions : nonNumericOpOptions}
            </select>

            <div className="btn-group">
              <button
                type="button"
                className="btn btn-default dropdown-toggle search-ex-menu-toggle"
                data-toggle="dropdown"
                aria-haspopup="true"
                aria-expanded="false"
              >
                <span className="glyphicon glyphicon-option-vertical"></span>
              </button>
              <ul className="dropdown-menu search-ex-menu-entries">
                {searchEx.subexpressions.length <
                  searchEx.maxSubexpressions() && (
                  <li>
                    <a
                      href="#"
                      className="search-ex-add-subexpression"
                      onClick={preventDefaultThen(() =>
                        setSearchEx(searchEx.withAdditionalSubexpression())
                      )}
                    >
                      Add
                    </a>
                  </li>
                )}

                <li>
                  <a href="#">Another action</a>
                </li>
                <li>
                  <a href="#">Something else here</a>
                </li>
                <li role="separator" className="divider"></li>
                {removeSearchEx && (
                  <li>
                    <a
                      href="#"
                      className="search-ex-delete"
                      onClick={preventDefaultThen(() =>
                        removeSearchEx(searchEx)
                      )}
                    >
                      Delete
                    </a>
                  </li>
                )}
              </ul>
            </div>
          </div>
          {otherDoodads(searchEx, setSearchEx)}
        </div>
        {0 === searchEx.subexpressions.length ? null : (
          <div className="search-ex-subexpressions">
            {searchEx.subexpressions.map(subex => (
              <SearchExEditor
                searchEx={subex}
                setSearchEx={newsub =>
                  setSearchEx(searchEx.replace(subex, newsub))
                }
                removeSearchEx={subexpressionRemoveFn}
              />
            ))}
          </div>
        )}
      </div>
    </div>
  )
}

const otherDoodads = (
  searchEx: SearchEx,
  setSearchEx: (se: SearchEx) => void
) => {
  if (searchEx instanceof FigureSearchEx) {
    return (
      <select
        className="form-control search-ex-figure"
        onChange={preventDefaultThen(({ target: { value } }) =>
          setSearchEx(searchEx.shallowCopy({ move: value }))
        )}
      >
        <option>swing</option>
        <option>do si do</option>
        <option>chain</option>
        <option>circle</option>
      </select>
    )
  } else {
    return null
  }
}

const preventDefaultThen = (funcToCall: (event: any) => void) => (event: {
  preventDefault: () => void
}) => {
  event.preventDefault()
  funcToCall(event)
}

export default SearchExEditor
