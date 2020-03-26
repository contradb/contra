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
}: {
  searchEx: SearchEx
  setSearchEx: (se: SearchEx) => void
}) => (
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
        </div>
        {otherDoodads(searchEx)}
      </div>
      {!searchEx.subexpressions.length ? (
        ""
      ) : (
        <div className="search-ex-subexpressions">
          {searchEx.subexpressions.map(subex => (
            <SearchExEditor
              searchEx={subex}
              setSearchEx={newsub =>
                setSearchEx(searchEx.replace(subex, newsub))
              }
            />
          ))}
        </div>
      )}
    </div>
  </div>
)

const otherDoodads = (searchEx: SearchEx) => {
  if (searchEx instanceof FigureSearchEx) {
    return "figures"
  } else {
    return null
  }
}

export default SearchExEditor
